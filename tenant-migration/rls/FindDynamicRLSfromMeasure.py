# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\FindDynamicRLSfromMeasure.py
# Attention: This code does not consider expanded measures, only measures that directly contain USERPRinCiPLENAME and are used in RLS roles.

# Purpose: Analyse JSON files in a folder from a Power BI tenant scan and find all dynamic RLS rules that use measures that use USERPRINCIPLENAME().
#          Export result to csv file.
# Author: Martin Bubenheimer
# Date: 2024-12-18
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import json
import csv

def find_filter_expressions(folder_path, output_csv):
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
                        for workspace in data['workspaces']:
                            if isinstance(workspace, dict) and 'datasets' in workspace:
                                for dataset in workspace['datasets']:
                                    # Step 1: Collect measure names with USERPRINCIPALNAME in expression
                                    measure_names = []
                                    if isinstance(dataset, dict) and 'tables' in dataset:
                                        for table in dataset['tables']:
                                            if isinstance(table, dict) and 'measures' in table:
                                                for measure in table['measures']:
                                                    # Check if measure contains USERPRINCIPALNAME
                                                    if (
                                                        isinstance(measure, dict) and
                                                        'expression' in measure and
                                                        measure['expression'] is not None and
                                                        isinstance(measure['expression'], str) and
                                                        'USERPRINCIPALNAME' in measure['expression'].upper()
                                                    ):
                                                        measure_names.append(measure.get('name', 'Unknown Measure'))
                                    print(f"Measure names found in dataset '{dataset.get('name', 'Unknown Dataset')}': {measure_names}")

                                    # Step 2: Search for these measure names in filterExpressions
                                    if 'roles' in dataset:
                                        for role in dataset['roles']:
                                            if isinstance(role, dict) and 'tablePermissions' in role:
                                                for permission in role['tablePermissions']:
                                                    # Check if the filterExpression references any measure name
                                                    if (
                                                        isinstance(permission, dict) and
                                                        'filterExpression' in permission and
                                                        permission['filterExpression'] is not None and
                                                        isinstance(permission['filterExpression'], str)
                                                    ):
                                                        filter_expression = permission['filterExpression']
                                                        for measure_name in measure_names:
                                                            if measure_name in filter_expression:
                                                                print(f"Match found in filterExpression: {filter_expression}")
                                                                # Replace line breaks in filterExpression with \n
                                                                clean_filter_expression = filter_expression.replace('\n', '\\n')
                                                                results.append({
                                                                    'workspace': workspace.get('name', 'Unknown Workspace'),
                                                                    'dataset': dataset.get('name', 'Unknown Dataset'),
                                                                    'role': role.get('name', 'Unknown Role'),
                                                                    'tablePermission': permission.get('name', 'Unknown Table'),
                                                                    'filterExpression': clean_filter_expression
                                                                })
                except json.JSONDecodeError:
                    print(f"Error parsing JSON in file: {file_name}")

    # Write results to CSV
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['workspace', 'dataset', 'role', 'tablePermission', 'filterExpression']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        writer.writerows(results)

    print(f"CSV file created: {output_csv}")

# Use a raw string for the folder path
folder_path = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-11-19"
output_csv = "C:/Scripts/Python/TenantScan/dynamic-rls-rules-from-measures.csv"

# Run the function
find_filter_expressions(folder_path, output_csv)
