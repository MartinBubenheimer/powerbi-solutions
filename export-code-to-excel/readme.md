# Power BI External Tool: Export Power BI Code to Excel

## Purpose
This tool adds a button to the External Tools ribbon in Microsoft Power BI that exports all Power Query and DAX code to an Excel file, including measures, calculated tables and calculated columns.

This allows users to search across all code, e.g. to find all code sections that refer to a certain field in case that field shall be removed. You can think of many, many more use cases.

## Setup
1. You need to create

    C:\Trusted

    as a trusted folder in Excel. See: [https://support.microsoft.com/en-us/office/add-remove-or-change-a-trusted-location-in-microsoft-office-7ee1cdc2-483e-4cbb-bcb3-4e7c67147fb4](https://support.microsoft.com/en-us/office/add-remove-or-change-a-trusted-location-in-microsoft-office-7ee1cdc2-483e-4cbb-bcb3-4e7c67147fb4)

    If you want to use a different folder, you can change the folder in file ExportCodeToExcel.pbitool.json. You can rename the ExportCodeToExcel part of the file name in order to sort the icons on your External Tools ribbon.

2. Copy the files ExportPowerBiCode.vbs and ExportPowerBiCode.xlsx to the trusted folder (C:\Trusted).

3. Copy the ExportCodeToExcel.pbitool.json file to your Power BI external tools folder which usually is 

    C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools

    Registering a tool requires a restart of Power BI Desktop.

    See: [https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-external-tools](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-external-tools)

4. When executing the external tool, the generated Excel file is stored in your personal OneDrive\Documents folder. This works only if you have synchronized OneDrive to your Documents folder. Otherwise you can change the folder in file ExportPowerBiCode.vbs in the docpath variable.

## Usage
1. In Power BI Desktop, click on the Export Code button on the External tools ribbon.
2. Excel opens. Wait for the dialog that asks for credential for the data source connection (steps 2. and 3. only occure the first time you export the code from the same Power BI file in the same Power BI Desktop session, i.e. the dialog occurs again if you open a different file or if you restart Power BI Desktop).
3. Choose to use credentials of the current Windows user and confirm.
4. Wait for data refresh to finish. Progress is indicated in the Excel status bar at the bottom of the Excel window.
5. You can browse the Power BI code on the different Excel sheets.

For further assitance send your problem description to <martin.bubenheimer@gmx.de>
