function Get-DbConnection {
    param(
        [string]$db_server,
        [string]$db_name,
        [string]$db_user,
        [string]$db_password
    )

    $connString = "Server=$db_server;Database=$db_name;User ID=$db_user;Password=$db_password;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connString
    $connection.Open()
    return $connection
}
