# Azure Function with PowerShell and Azure SQL Boilerplate

This boilerplate provides a starting point for creating an Azure Function with PowerShell that connects to an Azure SQL database and executes a stored procedure.

## Features

- **PowerShell-based:** The function is written in PowerShell, making it easy to integrate with other Azure services.
- **Azure SQL Integration:** The boilerplate includes a helper function for connecting to an Azure SQL database.
- **Stored Procedure Execution:** The function is designed to execute a stored procedure and return the results as a JSON object.
- **Environment Variable-based Configuration:** The database connection settings are managed through environment variables, which is a security best practice.

## Prerequisites

- An Azure account
- The Azure Functions Core Tools
- An Azure SQL database with a stored procedure

## Configuration

The function requires the following environment variables to be set in your `local.settings.json` file or in the function app's configuration in the Azure portal:

- `db_server`: The fully qualified domain name of your Azure SQL server.
- `db_name`: The name of your Azure SQL database.
- `db_user`: The username for connecting to your database.
- `db_password`: The password for your database user.
- `stored_procedure`: The name of the stored procedure to execute.

## Deployment

You can deploy this function to Azure using the Azure Functions Core Tools, Visual Studio Code, or the Azure portal.

## Usage

Once deployed, you can trigger the function by sending an HTTP request to its URL. The function will execute the stored procedure and return the results as a JSON object.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes.


CREATE USER func-cnn3-dev-api-integration FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [your-function-app-name];
ALTER ROLE db_datawriter ADD MEMBER [your-function-app-name];
GRANT EXECUTE TO [your-function-app-name];