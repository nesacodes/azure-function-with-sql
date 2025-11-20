# Import helper functions
. "$PSScriptRoot\helpers.ps1"

param($Request, $TriggerMetadata)

# Get environment variables for database connection
$db_server = $env:db_server
$db_name = $env:db_name
$stored_procedure = $env:stored_procedure


# Check if all required environment variables are set
if (-not ($db_server -and $db_name -and $db_user -and $db_password -and $stored_procedure)) {
    $body = "Missing required environment variables for database connection."
    $statusCode = 500
} else {
    try {
        # Get database connection
        $connection = Get-DbConnection -db_server $db_server -db_name $db_name -db_user $db_user -db_password $db_password

        # Prepare and execute the stored procedure
        $command = $connection.CreateCommand()
        $command.CommandText = $stored_procedure
        $command.CommandType = [System.Data.CommandType]::StoredProcedure

        # Example of adding a parameter. You'll need to adjust this based on your stored procedure.
        # $command.Parameters.AddWithValue("@YourParamName", "YourParamValue") | Out-Null

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) | Out-Null
        $connection.Close()

        # Convert the result to JSON
        $body = $dataset.Tables[0] | ConvertTo-Json
        $statusCode = 200

    } catch {
        $body = "Error executing stored procedure: $_"
        $statusCode = 500
    }
}

# Construct the HTTP response
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})
