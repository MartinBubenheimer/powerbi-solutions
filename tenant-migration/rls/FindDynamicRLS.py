# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\FindDynamicRLS.py

# Purpose: Analyse JSON files in a folder from a Power BI tenant scan and find all dynamic RLS rules that use USERPRINCIPLENAME().
#          Export result to csv file.
# Author: Martin Bubenheimer
# Date: 2024-12-18
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import json
import csv

def process_folder_and_generate_csv(folder_path, output_csv):
    results = []

    # Iterate through all files in the folder
    for file_name in os.listdir(folder_path):
        if file_name.lower().endswith('.json'):  # Process only JSON files
            file_path = os.path.join(folder_path, file_name)
            print(f"Processing file: {file_name}")  # Debugging

            # Open and parse the JSON file
            with open(file_path, 'r', encoding='utf-8') as file:
                try:
                    data = json.load(file)

                    # Check for the `workspaces` array
                    if isinstance(data, dict) and 'workspaces' in data:
                        print(f"'workspaces' found in file: {file_name}")
                        for workspace in data['workspaces']:
                            if isinstance(workspace, dict) and 'datasets' in workspace:
                                print(f"'datasets' found in workspace of file: {file_name}")
                                workspace_name = workspace.get('name', 'Unknown Workspace')

                                for dataset in workspace['datasets']:
                                    dataset_name = dataset.get('name', 'Unknown Dataset')

                                    if isinstance(dataset, dict) and 'roles' in dataset:
                                        print(f"'roles' found in dataset of file: {file_name}")
                                        for role in dataset['roles']:
                                            role_name = role.get('name', 'Unknown Role')

                                            if isinstance(role, dict) and 'tablePermissions' in role:
                                                for permission in role['tablePermissions']:
                                                    # Check for filterExpression and "USERPRINCIPALNAME"
                                                    if (
                                                        isinstance(permission, dict) and
                                                        'filterExpression' in permission and
                                                        permission['filterExpression'] is not None and
                                                        isinstance(permission['filterExpression'], str)
                                                    ):
                                                        filter_expression = permission['filterExpression']
                                                        print(f"Checking filterExpression: {filter_expression}")
                                                        
                                                        # Check if USERPRINCIPALNAME is found in the filterExpression
                                                        if 'USERPRINCIPALNAME' in filter_expression.upper():
                                                            print("USERPRINCIPALNAME found: Yes")
                                                        else:
                                                            print("USERPRINCIPALNAME found: No")
                                                        
                                                        # Now only match USERPRINCIPALNAME in filterExpression
                                                        if 'USERPRINCIPALNAME' in filter_expression.upper():  # Case insensitive
                                                            print(f"USERPRINCIPALNAME found in file: {file_name}")
                                                            # Replace newlines with "\n"
                                                            filter_expression = filter_expression.replace('\n', '\\n')

                                                            results.append({
                                                                'workspace': workspace_name,
                                                                'dataset': dataset_name,
                                                                'role': role_name,
                                                                'tablePermission': permission.get('name', 'Unknown Table'),
                                                                'filterExpression': filter_expression
                                                            })
                            else:
                                print(f"'datasets' not found in workspace of file: {file_name}")
                    else:
                        print(f"'workspaces' not found in file: {file_name}")
                except json.JSONDecodeError:
                    print(f"Error decoding JSON in file: {file_name}")

    # Write results to a CSV file with BOM (Byte Order Mark)
    with open(output_csv, 'w', newline='', encoding='utf-8-sig') as csvfile:
        fieldnames = ['workspace', 'dataset', 'role', 'tablePermission', 'filterExpression']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()  # This will include the header row in the CSV
        writer.writerows(results)

    print(f"CSV file created with {len(results)} matching rows: {output_csv}")

# Specify the folder path and output CSV file
folder_path = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-11-19"
output_csv = "C:/Scripts/Python/TenantScan/dynamic-rls-rules.csv"

# Run the function
process_folder_and_generate_csv(folder_path, output_csv)
