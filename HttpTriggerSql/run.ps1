using namespace System.Net
param($Request, $TriggerMetadata)

# Import helper functions
. "$PSScriptRoot\helpers.ps1"



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
        # $token = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token
        $resourceUri = "https://database.windows.net/"
        if ($env:IDENTITY_ENDPOINT -and $env:IDENTITY_HEADER) {
            # Newer Functions MSI pattern
            $tokenAuthUri = "${env:IDENTITY_ENDPOINT}?resource=$resourceUri&api-version=2019-08-01"
            $tokenResponse = Invoke-RestMethod -Method Get -Headers @{ "X-IDENTITY-HEADER" = $env:IDENTITY_HEADER } -Uri $tokenAuthUri
        }
        else {
            # Fallback to classic IMDS endpoint
            $tokenAuthUri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=$resourceUri"
            $tokenResponse = Invoke-RestMethod -Method Get -Headers @{ "Metadata" = "true" } -Uri $tokenAuthUri
        }

    $token = $tokenResponse.access_token

    if (-not $token) {
        throw "Failed to acquire access token from Managed Identity endpoint."
    }

    Write-Host "Token acquired successfully. Token length: $($token.Length)"
    Write-Host "Token response type: $($tokenResponse.token_type)"

        # Get database connection
        $connection = Get-DbConnection -sqlServer $sqlServer -sqlDatabase $sqlDatabase -token $token
    
        # Create SQL Command for Stored Procedure
        $command = New-Object System.Data.SqlClient.SqlCommand
        $command.Connection = $connection
        $command.CommandText = $storedProcName
        $command.CommandType = [System.Data.CommandType]::StoredProcedure

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
    finally {
        if ($connection) {
            $connection.Close()
            Write-Host "Connection closed"
        }
    }
}


   
    
   
    