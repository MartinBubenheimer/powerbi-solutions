# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\GatewaysAndConnections.py

# Purpose: Analyse gateways from REST API, connections from REST API, datasets from tenant scan, and dataflows from tenant scan to list which
#          which gateways are in use and which data sources are used by which dataset or dataflow Gen 1.
#          Export result to csv file.
#          To do: Needs some clean up to align appended columns.
# Author: Martin Bubenheimer
# Date: 2024-12-20
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import requests
import json
import pandas as pd
from msal import PublicClientApplication

def extract_gateways_from_file(json_file_path):
    """
    Extracts id, name, and type from the provided JSON file containing gateway information.

    Args:
        json_file_path (str): Path to the JSON file.

    Returns:
        DataFrame: A DataFrame containing the id, name, and type of each gateway.
    """
    with open(json_file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        gateways = data.get("value", [])

        gateway_list = [
            {
                "id": gateway.get("id"),
                "name": gateway.get("name"),
                "type": gateway.get("type")
            }
            for gateway in gateways
        ]

        # Convert the list to a DataFrame for better presentation
        return pd.DataFrame(gateway_list)

def extract_connections_from_folder(folder_path):
    """
    Extracts connection details from multiple JSON files in a folder, including unpacking connectionDetails.

    Args:
        folder_path (str): Path to the folder containing connection JSON files.

    Returns:
        DataFrame: A DataFrame containing the gatewayId, connection id, datasourceType, and unpacked connectionDetails.
    """
    connections = []

    for file_name in os.listdir(folder_path):
        if file_name.endswith(".json"):
            file_path = os.path.join(folder_path, file_name)
            with open(file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)
                for connection in data.get("value", []):
                    connection_details = connection.get("connectionDetails")
                    if isinstance(connection_details, str):
                        try:
                            connection_details = json.loads(connection_details)
                        except json.JSONDecodeError:
                            print(f"Invalid JSON in connectionDetails: {connection_details}")
                            connection_details = {}
                    elif not isinstance(connection_details, dict):
                        connection_details = {}

                    # Flatten connectionDetails into individual fields
                    connections.append({
                        "gatewayId": connection.get("gatewayId"),
                        "connectionId": connection.get("id"),
                        "datasourceType_gateway": connection.get("datasourceType"),
                        **connection_details  # Unpack all attributes from connectionDetails
                    })

    # Convert the list to a DataFrame for better presentation
    return pd.DataFrame(connections)

def extract_datasets_from_folder(folder_path):
    """
    Extracts workspace, dataset, dataflow, and datasource information from JSON files in the folder.

    Args:
        folder_path (str): Path to the folder containing dataset JSON files.

    Returns:
        DataFrame: A DataFrame with extracted workspace, dataset, and datasource information.
    """
    datasets = []

    for file_name in os.listdir(folder_path):
        if file_name.endswith(".json"):
            file_path = os.path.join(folder_path, file_name)
            with open(file_path, 'r', encoding='utf-8') as file:
                data = json.load(file)

                workspaces = data.get("workspaces", [])
                datasource_instances = {}
                for instance in data.get("datasourceInstances", []):
                    connection_details = instance.get("connectionDetails")
                    if isinstance(connection_details, str):
                        try:
                            connection_details = json.loads(connection_details)
                        except json.JSONDecodeError:
                            print(f"Invalid JSON in connectionDetails: {connection_details}")
                            connection_details = {}
                    elif not isinstance(connection_details, dict):
                        connection_details = {}

                    datasource_instances[instance.get("datasourceId")] = {
                        "datasourceId": instance.get("datasourceId"),
                        "datasourceType": instance.get("datasourceType"),
                        **connection_details
                    }

                for workspace in workspaces:
                    workspace_name = workspace.get("name")

                    # Extract datasets
                    for dataset in workspace.get("datasets", []):
                        dataset_name = dataset.get("name")
                        configured_by = dataset.get("configuredBy")
                        refresh_schedule = dataset.get("refreshSchedule", {})
                        refresh_enabled = refresh_schedule.get("enabled", None)

                        for usage in dataset.get("datasourceUsages", []):
                            instance_id = usage.get("datasourceInstanceId")
                            instance_details = datasource_instances.get(instance_id, {})

                            datasets.append({
                                "workspaceName": workspace_name,
                                "name": dataset_name,
                                "configuredBy": configured_by,
                                "refreshEnabled": refresh_enabled,
                                "datasourceId": instance_details.get("datasourceId"),
                                "datasourceType": instance_details.get("datasourceType"),
                                "type": "Dataset",  # Mark this as dataset
                                **instance_details
                            })

                    # Extract dataflows
                    for dataflow in workspace.get("dataflows", []):
                        dataflow_name = dataflow.get("name")
                        configured_by = dataflow.get("configuredBy")
                        refresh_schedule = dataflow.get("refreshSchedule", {})
                        refresh_enabled = refresh_schedule.get("enabled", None)

                        for usage in dataflow.get("datasourceUsages", []):
                            instance_id = usage.get("datasourceInstanceId")
                            instance_details = datasource_instances.get(instance_id, {})

                            datasets.append({
                                "workspaceName": workspace_name,
                                "name": dataflow_name,
                                "configuredBy": configured_by,
                                "refreshEnabled": refresh_enabled,
                                "datasourceId": instance_details.get("datasourceId"),
                                "datasourceType": instance_details.get("datasourceType"),
                                "type": "Dataflow",  # Mark this as dataflow
                                **instance_details
                            })

    # Convert the list to a DataFrame for better presentation
    return pd.DataFrame(datasets)

def main():
    gateways_file_path = "C:/Users/adm-odbc-gateway/Downloads/gateways-c93f2f2c-80b9-4410-96f8-214f2725ddb2-20241220_185334.json"
    connections_folder_path = "C:/Users/adm-odbc-gateway/Downloads/connections/"
    datasets_folder_path = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-12-18/"
    output_csv = "C:/Scripts/Python/TenantScan/gateways-connections.csv"

    try:
        # Step 1: Extract gateways from the main JSON file
        gateway_df = extract_gateways_from_file(gateways_file_path)

        # Step 2: Extract connections from multiple files in the folder
        connections_df = extract_connections_from_folder(connections_folder_path)

        # Step 3: Extract datasets and dataflows from workspace files
        datasets_df = extract_datasets_from_folder(datasets_folder_path)

        # Step 4: Merge connections with gateways to include gateway names and types
        connections_with_gateways = pd.merge(
            connections_df,
            gateway_df,
            left_on="gatewayId",
            right_on="id",
            how="left"
        )

        # Step 5: Match datasets and dataflows to connections (inner join)
        matched_df = pd.merge(
            datasets_df,
            connections_with_gateways,
            left_on="datasourceId",
            right_on="connectionId",
            how="inner",
            suffixes=("_dataset", "_connection")
        )

        # Step 6: Identify unmatched datasets and dataflows
        unmatched_datasets = datasets_df[~datasets_df["datasourceId"].isin(connections_with_gateways["connectionId"])]
        unmatched_datasets = unmatched_datasets.assign(name=None, type=None)

        # Step 7: Identify unmatched connections
        unmatched_connections = connections_with_gateways[~connections_with_gateways["connectionId"].isin(datasets_df["datasourceId"])]
        unmatched_connections = unmatched_connections.assign(
            workspaceName=None,
            name=None,
            configuredBy=None
        )

        # Step 8: Identify gateways without connections
        valid_connections = connections_df[connections_df["connectionId"].notna()]
        gateways_with_connections = valid_connections["gatewayId"].unique()
        gateways_without_connections = gateway_df[~gateway_df["id"].isin(gateways_with_connections)]
        gateways_without_connections = gateways_without_connections.assign(
            connectionId=None,
            datasourceType=None,
            workspaceName=None,
            name=None,
            configuredBy=None,
            refreshEnabled=None,
            type=None
        )

        # Step 9: Concatenate results
        final_df = pd.concat([matched_df, unmatched_datasets, unmatched_connections, gateways_without_connections], ignore_index=True)

        # Display the final DataFrame
        print("Gateways with Connections and Datasets:")
        print(final_df)

        # Save the final results to a CSV file
        final_df.to_csv(output_csv, index=False)
        print(f"The list of gateways with connections, datasets, and dataflows has been saved to '{output_csv}'.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
