using System.Text.Json;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.DependencyInjection;

namespace AksPlatform.Sdk;

public sealed record PlatformTelemetryClient(
    bool Enabled,
    string ServiceName,
    TelemetryClient? ApplicationInsights = null)
{
    public void TrackEvent(string name, IReadOnlyDictionary<string, string>? properties = null)
    {
        if (!Enabled)
        {
            return;
        }

        var eventProperties = new Dictionary<string, string>(properties ?? new Dictionary<string, string>())
        {
            ["serviceName"] = ServiceName
        };

        ApplicationInsights?.TrackEvent(name, eventProperties);
    }

    public void Flush() => ApplicationInsights?.Flush();
}

public static class PlatformTelemetry
{
    public static PlatformTelemetryClient Configure(
        string serviceName,
        string? connectionString,
        bool enabled = true)
    {
        if (!enabled || string.IsNullOrWhiteSpace(connectionString))
        {
            return new PlatformTelemetryClient(false, serviceName);
        }

        System.Environment.SetEnvironmentVariable("APPLICATIONINSIGHTS_CONNECTION_STRING", connectionString);
        System.Environment.SetEnvironmentVariable("APPLICATIONINSIGHTS_ROLE_NAME", serviceName);

        var configuration = TelemetryConfiguration.CreateDefault();
        configuration.ConnectionString = connectionString;
        configuration.TelemetryInitializers.Add(new CloudRoleNameInitializer(serviceName));

        return new PlatformTelemetryClient(true, serviceName, new TelemetryClient(configuration));
    }

    public static IServiceCollection AddPlatformApplicationInsights(
        this IServiceCollection services,
        PlatformConfig config,
        bool enabled = true)
    {
        if (!enabled || string.IsNullOrWhiteSpace(config.ApplicationInsightsConnectionString))
        {
            return services;
        }

        services.AddApplicationInsightsTelemetry(options =>
        {
            options.ConnectionString = config.ApplicationInsightsConnectionString;
        });
        services.AddSingleton<ITelemetryInitializer>(new CloudRoleNameInitializer(config.ServiceName));
        return services;
    }
}

internal sealed class CloudRoleNameInitializer(string serviceName) : ITelemetryInitializer
{
    public void Initialize(ITelemetry telemetry)
    {
        telemetry.Context.Cloud.RoleName = serviceName;
    }
}
