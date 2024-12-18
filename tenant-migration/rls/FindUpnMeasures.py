# Run: "C:\Program Files\Python313\python.exe" C:\Scripts\Python\TenantScan\FindUpnMeasures.py

# Purpose: Analyse JSON files in a folder from a Power BI tenant scan and find all measures that use USERPRINCIPLENAME().
#          Export result to csv file.
# Author: Martin Bubenheimer
# Date: 2024-12-18
# Compatibility: Tested with Python 3.13.1 on Windows 11 64 bit

import os
import json
import csv

def find_userprincipalname_in_measures(folder_path, output_csv):
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
                                for dataset in workspace['datasets']:
                                    if isinstance(dataset, dict) and 'tables' in dataset:
                                        print(f"'tables' found in dataset of file: {file_name}")
                                        for table in dataset['tables']:
                                            if isinstance(table, dict) and 'measures' in table:
                                                for measure in table['measures']:
                                                    # Check for `expression` in each measure
                                                    if (
                                                        isinstance(measure, dict) and
                                                        'expression' in measure and
                                                        measure['expression'] is not None and
                                                        isinstance(measure['expression'], str)
                                                    ):
                                                        print(f"Checking expression: {measure['expression']}")
                                                        if 'USERPRINCIPALNAME' in measure['expression'].upper():  # Case insensitive
                                                            print(f"'USERPRINCIPALNAME' found in file: {file_name}")
                                                            # Replace line breaks with \n in the expression
                                                            clean_expression = measure['expression'].replace('\n', '\\n')
                                                            results.append({
                                                                'workspace': workspace.get('name', 'Unknown Workspace'),
                                                                'dataset': dataset.get('name', 'Unknown Dataset'),
                                                                'table': table.get('name', 'Unknown Table'),
                                                                'measure': measure.get('name', 'Unknown Measure'),
                                                                'expression': clean_expression
                                                            })
                            else:
                                print(f"'tables' not found in dataset of file: {file_name}")
                    else:
                        print(f"'workspaces' not found in file: {file_name}")
                except json.JSONDecodeError:
                    print(f"Error parsing JSON in file: {file_name}")

    # Write results to CSV
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['workspace', 'dataset', 'table', 'measure', 'expression']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        writer.writerows(results)

    print(f"CSV file created: {output_csv}")

# Use a string for the folder path
folder_path = "C:/Users/adm-odbc-gateway/Downloads/DSE Tenant Scan 2024-11-19"
output_csv = "C:/Scripts/Python/TenantScan/upn-measures.csv"

# Run the function
find_userprincipalname_in_measures(folder_path, output_csv)
