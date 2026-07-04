from dataclasses import dataclass
from typing import Any

from .credential import create_default_credential


def create_entra_sql_connection_string(server: str, database: str) -> str:
    if not server.strip():
        raise ValueError("Azure SQL server host is required.")
    if not database.strip():
        raise ValueError("Azure SQL database name is required.")

    return (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server=tcp:{server.strip()},1433;"
        f"Database={database.strip()};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )


@dataclass
class SqlDatabaseClient:
    server: str
    database: str
    credential: Any | None = None

    def __post_init__(self) -> None:
        import pyodbc

        credential = self.credential or create_default_credential()
        token = credential.get_token("https://database.windows.net/.default").token
        self._connection = pyodbc.connect(
            create_entra_sql_connection_string(self.server, self.database),
            attrs_before={1256: bytes(token, "utf-16-le")},
        )

    def query(self, sql: str, parameters: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
        cursor = self._connection.cursor()
        cursor.execute(sql, parameters)
        columns = [column[0] for column in cursor.description or []]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]

    def close(self) -> None:
        self._connection.close()
