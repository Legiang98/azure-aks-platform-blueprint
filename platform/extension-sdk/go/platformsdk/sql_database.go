package platformsdk

import (
	"fmt"
	"net/url"
)

func EntraSQLConnectionString(server string, database string) (string, error) {
	if server == "" {
		return "", fmt.Errorf("Azure SQL server host is required")
	}
	if database == "" {
		return "", fmt.Errorf("Azure SQL database name is required")
	}

	values := url.Values{}
	values.Set("database", database)
	values.Set("encrypt", "true")
	values.Set("trustservercertificate", "false")
	values.Set("fedauth", "ActiveDirectoryDefault")

	return fmt.Sprintf("sqlserver://%s:1433?%s", server, values.Encode()), nil
}
