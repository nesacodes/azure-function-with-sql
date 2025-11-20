# Import helper functions
. "$PSScriptRoot\helpers.ps1"

param($Request, $TriggerMetadata)

# Get configuration from Application Settings
$sqlServer = $env:SQL_SERVER  # e.g., "myserver.database.windows.net"
$sqlDatabase = $env:SQL_DATABASE
$storedProcName = $env:STORED_PROC_NAME  # e.g., "dbo.MyStoredProcedure"



Write-Host "PowerShell HTTP trigger function processed a request."

# Check if all required environment variables are set
if (-not ($sqlServer -and $sqlDatabase -and $storedProcName)) {
    $body = "Missing required environment variables for database connection."
    $statusCode = 500
     Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = $statusCode
                Body       = $body
                Headers    = @{
                    "Content-Type" = "application/json"
                }
            })
}
else {
    try {
        # Get Access Token using Managed Identity
        Write-Host "Acquiring access token using Managed Identity..."
        $token = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token

        # Get database connection
        $connection = Get-DbConnection -sqlServer $sqlServer -sqlDatabase $sqlDatabase -token $token

        # Prepare and execute the stored procedure
        # $command = $connection.CreateCommand()
        # $command.CommandText = $stored_procedure
        # $command.CommandType = [System.Data.CommandType]::StoredProcedure

        # Example of adding a parameter. You'll need to adjust this based on your stored procedure.
        # $command.Parameters.AddWithValue("@YourParamName", "YourParamValue") | Out-Null

        # $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        # $dataset = New-Object System.Data.DataSet
        # $adapter.Fill($dataset) | Out-Null
        # $connection.Close()

        # Convert the result to JSON
        # $body = $dataset.Tables[0] | ConvertTo-Json
        # $statusCode = 200

        
        # Create SQL Command for Stored Procedure
        $command = New-Object System.Data.SqlClient.SqlCommand
        $command.Connection = $connection
        $command.CommandText = $storedProcName
        $command.CommandType = [System.Data.CommandType]::StoredProcedure
    
        # Add parameters if your stored procedure needs them
        # Example:
        # $param1 = $Request.Query.Param1
        # if ($param1) {
        #     $command.Parameters.AddWithValue("@Param1", $param1) | Out-Null
        # }
    
        # Execute stored procedure and get results
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $dataset = New-Object System.Data.DataSet
        $rowsAffected = $adapter.Fill($dataset)
    
        Write-Host "Stored procedure executed. Rows affected: $rowsAffected"
    
        # Process results
        $results = @()
        if ($dataset.Tables.Count -gt 0 -and $dataset.Tables[0].Rows.Count -gt 0) {
            foreach ($row in $dataset.Tables[0].Rows) {
                $rowData = @{}
                foreach ($column in $dataset.Tables[0].Columns) {
                    $rowData[$column.ColumnName] = $row[$column.ColumnName]
                }
                $results += $rowData
            }
        }
    
        # Close connection
        $connection.Close()
        Write-Host "Connection closed"
    
        # Return success response
        $body = @{
            status   = "success"
            message  = "Stored procedure executed successfully"
            rowCount = $results.Count
            data     = $results
        } | ConvertTo-Json -Depth 10
    
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [HttpStatusCode]::OK
                Body       = $body
                Headers    = @{
                    "Content-Type" = "application/json"
                }
            })
    }
    catch {
        Write-Host "Error occurred: $($_.Exception.Message)"
        Write-Host "Stack trace: $($_.Exception.StackTrace)"
    
        $errorBody = @{
            status  = "error"
            message = $_.Exception.Message
            details = $_.Exception.StackTrace
        } | ConvertTo-Json
    
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [HttpStatusCode]::InternalServerError
                Body       = $errorBody
                Headers    = @{
                    "Content-Type" = "application/json"
                }
            })
    }
}


   
    
   
    