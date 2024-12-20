# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\FindSnowflakeUsers.py

# Purpose: List all users that have configured a dataset with a Snowflake datasource.
#          Export result to csv file.
# Author: Martin Bubenheimer
# Date: 2024-12-20
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import json
import csv

def collect_snowflake_datasources(folder_path):
    """
    Collect all Snowflake datasourceId values and their extensionDataSourcePath
    from the top-level datasourceInstances array.
    """
    snowflake_datasources = {}

    for file_name in os.listdir(folder_path):
        if file_name.endswith('.json'):  # Only process JSON files
            file_path = os.path.join(folder_path, file_name)
            with open(file_path, 'r', encoding='utf-8') as file:
                try:
                    data = json.load(file)

                    # Check the top-level datasourceInstances array
                    for instance in data.get("datasourceInstances", []):
                        connection_details = instance.get("connectionDetails", {})
                        if connection_details.get("extensionDataSourceKind") == "Snowflake":
                            datasource_id = instance.get("datasourceId")
                            extension_data_source_path = connection_details.get("extensionDataSourcePath", "Unknown")
                            if datasource_id:
                                # Store datasourceId and extensionDataSourcePath
                                snowflake_datasources[datasource_id] = extension_data_source_path

                except json.JSONDecodeError:
                    print(f"Error reading JSON file: {file_path}")

    return snowflake_datasources


def find_matching_datasets(folder_path, snowflake_datasources):
    """
    Find datasets with datasourceInstanceId matching Snowflake datasourceIds.
    """
    matching_datasets = []

    for file_name in os.listdir(folder_path):
        if file_name.endswith('.json'):  # Only process JSON files
            file_path = os.path.join(folder_path, file_name)
            with open(file_path, 'r', encoding='utf-8') as file:
                try:
                    data = json.load(file)

                    # Check workspaces and their datasets
                    for workspace in data.get("workspaces", []):
                        workspace_name = workspace.get("name", "Unknown Workspace")
                        for dataset in workspace.get("datasets", []):
                            dataset_name = dataset.get("name", "Unknown Dataset")
                            configured_by = dataset.get("configuredBy", "Unknown User")
                            # Check for refreshSchedule and its enabled attribute
                            refresh_schedule = dataset.get("refreshSchedule", {})
                            enabled = refresh_schedule.get("enabled", "Unknown")
                            for usage in dataset.get("datasourceUsages", []):
                                datasource_instance_id = usage.get("datasourceInstanceId")
                                if datasource_instance_id in snowflake_datasources:
                                    matching_datasets.append({
                                        "workspace": workspace_name,
                                        "dataset": dataset_name,
                                        "configuredBy": configured_by,
                                        "datasourceId": datasource_instance_id,
                                        "datasourceInstanceId": datasource_instance_id,
                                        "extensionDataSourcePath": snowflake_datasources[datasource_instance_id],
                                        "refreshEnabled": enabled
                                    })

                except json.JSONDecodeError:
                    print(f"Error reading JSON file: {file_path}")

    return matching_datasets


def process_folder(folder_path, output_csv):
    """
    Process the folder to find matching datasets and write the results to a CSV file.
    """
    # Step 1: Collect all Snowflake datasourceIds and extensionDataSourcePath
    snowflake_datasources = collect_snowflake_datasources(folder_path)
    print(f"Collected Snowflake DatasourceIds: {snowflake_datasources}")

    # Step 2: Find all matching datasets
    matching_datasets = find_matching_datasets(folder_path, snowflake_datasources)

    # Step 3: Write results to CSV
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['workspace', 'dataset', 'configuredBy', 'datasourceId', 'datasourceInstanceId', 'extensionDataSourcePath', 'refreshEnabled']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        if matching_datasets:
            writer.writerows(matching_datasets)
        else:
            print("No matching datasets found.")

    print(f"CSV file created: {output_csv}")


# Input folder and output CSV file path
input_folder = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-12-18"
output_csv = "C:/Scripts/Python/TenantScan/snowflake-users.csv"

# Run the script
process_folder(input_folder, output_csv)
