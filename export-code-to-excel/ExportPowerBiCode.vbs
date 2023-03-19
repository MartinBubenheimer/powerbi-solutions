'This is VBScript code. Don't mix up with Visual Basic for Applications (VBA) or other flavours of Visual Basic code!
'
'Author: Martin Bubenheimer
'Last changed: 2022-03-18
'
'Purpose: Export M (Power Query) and DAX code from Power BI Desktop to Excel, e.g. for
'- full text search in code across the whole file
'- backup code before changes
'- copy code to new measures, queries, or other files
'
'Important:
'- User needs to confirm to use current Windows user's credentials for access to Power BI Desktop connection
'- User needs to save Excel file manually after refresh otherwise the stored file is just a copy of the template.
'
'This script is designed to be used as an external tool in Microsoft Power BI Desktop.
'
'Arguments:
'First argument: Excel template file including full path, e.g. "C:\Template.xlsx"
'Second argument: Server in the format "localhost:12345".
'
'This script copies an Excel template file to the personal OneDrive Documents folder, 
'inserts the current Power BI Desktop port number and refreshes the queries in Excel.

'VBScript does not require typed variables
dim XL
dim WB
dim args
dim arg
dim ServerArgs
dim port
dim docpath
dim destinationfilename
dim destinationfile
dim sourcefile
dim saveNow

'Get current date and time to create unique file name for Excel file
saveNow = Now

'Get port number  from command line parameters
set args=wscript.arguments
ServerArgs = Split(args(1), ":")
port = ServerArgs(1)

'Get user path from system environment variable
'VBScript uses a Shell object to access environment variables.
Dim wshShell
Set wshShell = CreateObject( "WScript.Shell" )
docpath = wshShell.ExpandEnvironmentStrings( "%USERPROFILE%" ) & "\OneDrive\Documents"

sourcefile = args(0)
destinationfilename = "ExportPowerBiCode_" & Replace(Replace(Replace(Replace(FormatDateTime(saveNow), " ", "_"), ":", "-"), ".", "-"), "/", "_") & ".xlsx"
destinationfile = docpath & "\" & destinationfilename

'Copy template file to OneDrive Documents folder with unique filename
'VBScript uses a FileSystemObject for file system operations like copy.
Dim FSO
Set FSO = CreateObject("Scripting.FileSystemObject")
FSO.CopyFile sourcefile, destinationfile

'Open copy of Excel file, insert port number an trigger refresh
'VBScript uses an Excel Apllication object for Excel operations.
set XL=createobject("Excel.Application")
xl.visible=1
set WB=XL.Workbooks.Open(destinationfile)
Wb.worksheets(1).Range("Port")(1).value=port
Wb.RefreshAll
'RefreshAll does not wait until refresh is done before it terminates
'Script.Sleep 1000
'Wb.Save
