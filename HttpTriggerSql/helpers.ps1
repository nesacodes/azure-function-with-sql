function Get-DbConnection {
    param(
        [string]$sqlServer,
        [string]$sqlDatabase,
        [string]$token
    )
 # Build connection string (no username/password needed)
    $connectionString = "Server=tcp:$sqlServer,1433;Database=$sqlDatabase;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    # Create SQL Connection with Access Token
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.AccessToken = $token  # This is the key for Managed Identity auth
    
    # Open connection
    $connection.Open()
    Write-Host "Connected to SQL Database successfully using Managed Identity"
    # $connString = "Server=$db_server;Database=$db_name;User ID=$db_user;Password=$db_password;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
    # $connection = New-Object System.Data.SqlClient.SqlConnection
    # $connection.ConnectionString = $connString
    # $connection.Open()
    return $connection

    
    
}
