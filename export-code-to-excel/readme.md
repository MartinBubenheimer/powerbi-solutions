# Power BI External Tool: Export Power BI Code to Excel

## Purpose
This tool adds a button to the External Tools ribbon in Microsoft Power BI that exports all Power Query and DAX code to an Excel file, including measures, calculated tables and calculated columns.

This allows users to search across all code, e.g. to find all code sections that refer to a certain field in case that field shall be removed. You can think of many, many more use cases.

## Setup
Copy the ExportCodeToExcel.pbitool.json file to your Power BI external tools folder which usually is 

    C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools

Registering a tool requires a restart of Power BI Desktop.
See: [https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-external-tools](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-external-tools)

## Usage
