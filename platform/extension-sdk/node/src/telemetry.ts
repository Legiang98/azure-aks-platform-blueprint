export interface PlatformTelemetryOptions {
  serviceName: string;
  connectionString?: string;
  enabled?: boolean;
}

export interface PlatformTelemetryClient {
  enabled: boolean;
  trackEvent(name: string, properties?: Record<string, string>): void;
  flush(): Promise<void>;
}

export async function configurePlatformTelemetry(options: PlatformTelemetryOptions): Promise<PlatformTelemetryClient> {
  if (options.enabled === false || !options.connectionString) {
    return noopTelemetryClient;
  }

  process.env.APPLICATIONINSIGHTS_CONNECTION_STRING = options.connectionString;
  process.env.APPLICATIONINSIGHTS_ROLE_NAME = options.serviceName;

  const applicationInsights = await import("applicationinsights");
  const appInsights = applicationInsights.default ?? applicationInsights;

  appInsights
    .setup(options.connectionString)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true, true)
    .setUseDiskRetryCaching(true)
    .start();

  return {
    enabled: true,
    trackEvent(name: string, properties?: Record<string, string>): void {
      appInsights.defaultClient?.trackEvent({
        name,
        properties: {
          serviceName: options.serviceName,
          ...properties
        }
      });
    },
    async flush(): Promise<void> {
      await new Promise<void>((resolve) => {
        appInsights.defaultClient?.flush({
          callback: () => resolve()
        }) ?? resolve();
      });
    }
  };
}

const noopTelemetryClient: PlatformTelemetryClient = {
  enabled: false,
  trackEvent(): void {
    return;
  },
  async flush(): Promise<void> {
    return;
  }
};
