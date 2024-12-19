# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\FindSharePointSourcesOfDataflows.py

# Purpose: Analyse JSON files in a folder from a Power BI tenant scan and find all SharePoint Online data sources used in dataflows Gen 1
#          Export result to csv file.
# Author: Martin Bubenheimer
# Date: 2024-12-18
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import json
import csv

def extract_and_join_datasources(folder_path, output_csv):
    datasource_records = []
    matching_datasource_ids = {}

    # Step 1: Collect matching datasource IDs and their details
    for file_name in os.listdir(folder_path):
        if file_name.lower().endswith('.json'):  # Process only JSON files
            file_path = os.path.join(folder_path, file_name)
            print(f"Processing file for datasourceInstances: {file_name}")  # Debugging

            with open(file_path, 'r', encoding='utf-8') as file:
                try:
                    data = json.load(file)

                    if isinstance(data, dict) and 'datasourceInstances' in data:
                        for instance in data['datasourceInstances']:
                            if (
                                isinstance(instance, dict) and
                                'datasourceId' in instance and
                                'datasourceType' in instance and
                                'connectionDetails' in instance and
                                isinstance(instance['connectionDetails'], dict)
                            ):
                                # Check for URL or SharePointSiteUrl
                                connection_details = instance['connectionDetails']
                                url = None

                                for key in connection_details.keys():
                                    if key.lower() in ['url', 'sharepointsiteurl']:
                                        if '.sharepoint.com/' in connection_details[key].lower():
                                            url = connection_details[key]
                                            break

                                if url:
                                    datasource_id = instance['datasourceId']
                                    matching_datasource_ids[datasource_id] = {
                                        'datasourceId': datasource_id,
                                        'datasourceType': instance['datasourceType'],
                                        'url': url,
                                        'workspace': None,
                                        'dataflow': None,
                                        'enabled': None,  # Default to None until matched with dataflow
                                        'configuredBy': None  # Default to None
                                    }
                except json.JSONDecodeError:
                    print(f"Error parsing JSON in file: {file_name}")

    # Step 2: Find dataflows using the matching datasource IDs and join them
    for file_name in os.listdir(folder_path):
        if file_name.lower().endswith('.json'):  # Process only JSON files
            file_path = os.path.join(folder_path, file_name)
            print(f"Processing file for dataflows: {file_name}")  # Debugging

            with open(file_path, 'r', encoding='utf-8') as file:
                try:
                    data = json.load(file)

                    if isinstance(data, dict) and 'workspaces' in data:
                        for workspace in data['workspaces']:
                            workspace_name = workspace.get('name', 'Unknown Workspace')
                            if isinstance(workspace, dict) and 'dataflows' in workspace:
                                for dataflow in workspace['dataflows']:
                                    dataflow_name = dataflow.get('name', 'Unknown Dataflow')
                                    enabled = dataflow.get('refreshSchedule', {}).get('enabled', None)
                                    configured_by = dataflow.get('configuredBy', 'Unknown ConfiguredBy')
                                    if isinstance(dataflow, dict) and 'datasourceUsages' in dataflow:
                                        for usage in dataflow['datasourceUsages']:
                                            if (
                                                isinstance(usage, dict) and
                                                'datasourceInstanceId' in usage
                                            ):
                                                datasource_id = usage['datasourceInstanceId']
                                                if datasource_id in matching_datasource_ids:
                                                    # Join the dataflow info with the datasource record
                                                    datasource_records.append({
                                                        'datasourceId': datasource_id,
                                                        'datasourceType': matching_datasource_ids[datasource_id]['datasourceType'],
                                                        'url': matching_datasource_ids[datasource_id]['url'],
                                                        'workspace': workspace_name,
                                                        'dataflow': dataflow_name,
                                                        'enabled': enabled,
                                                        'configuredBy': configured_by
                                                    })
                except json.JSONDecodeError:
                    print(f"Error parsing JSON in file: {file_name}")

    # Write results to CSV
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['datasourceId', 'datasourceType', 'url', 'workspace', 'dataflow', 'enabled', 'configuredBy']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        writer.writerows(datasource_records)

    print(f"CSV file created: {output_csv}")

# Use a raw string for the folder path
folder_path = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-12-18"
output_csv = "C:/Scripts/Python/TenantScan/sharepoint-sources-dataflows.csv"

# Run the function
extract_and_join_datasources(folder_path, output_csv)
