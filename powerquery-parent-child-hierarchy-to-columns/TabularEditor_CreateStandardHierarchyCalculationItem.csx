#r "Microsoft.VisualBasic"
using Microsoft.VisualBasic;

// Script creates standard hierachy calculation item for each selected hierarchy
// !!! You must select a HIERARCHY first, then execute this script! !!!

// Backlog:
// Add code to hide columns in the tables containing the hierarchies:
// (First three columns might require to loop over all columns, and if name matches, then set hidden flag.)
// - Path
// - Path Length
// - Children
// - All columns serving the levels (Level.Column.IsHidden = true
// (Last line requires a loop over all levels.)

string strHierachyCalcGroupTableName = "💻 Hierachy";
string strCalcGroupName = "Base Hierarchy";

bool bCreateCalculationGroup = true;

CalculationGroupTable cgtHierachyCalcGroupTable = null as CalculationGroupTable;

// Check whether calculation group for hierarchy context already exist or create
foreach(var ct in Model.CalculationGroups) {
    if(ct.Name == strHierachyCalcGroupTableName) {
        cgtHierachyCalcGroupTable = ct;
        bCreateCalculationGroup = false;
    }
}
   
if(bCreateCalculationGroup) {
    var ctHierachyCalcGroupTable = Model.AddCalculationGroup();
    (Model.Tables["New Calculation Group"] as CalculationGroupTable).CalculationGroup.Precedence = 1;
    ctHierachyCalcGroupTable.Name = strHierachyCalcGroupTableName;
    ctHierachyCalcGroupTable.Columns["Name"].Name = strCalcGroupName;
    cgtHierachyCalcGroupTable = ctHierachyCalcGroupTable;
}

// loop through selected hierachies
foreach(var h in Selected.Hierarchies) {

// Mark hierarchy as unbalanced, so frontend tools like Excel do not even need to apply the calculation group
    h.HideMembers = HierarchyHideMembersType.HideBlankMembers;
    
// get name of hierachy
    string strHierachyName = h.Name;
    
// Check for exiting calculation item or create, 
    bool bCreateCalculationItem = true;
    CalculationItem ciHierachy = null as CalculationItem;

    foreach(var ci in cgtHierachyCalcGroupTable.CalculationItems) {
        if(ci.Name == strHierachyName + " Standard") {
            ciHierachy = ci;
            bCreateCalculationItem = false;
        }
    }
    
    if(bCreateCalculationItem){
        // generate name of calcualtion item as hierachy name + Standard
        ciHierachy = cgtHierachyCalcGroupTable.AddCalculationItem(strHierachyName + " Standard");
    }

// generate DAX measure code for all hierachy elements
    string strScope = "";
    int iLevelCount = 0;
    foreach(var l in h.Levels) {
        if(iLevelCount == 0) {
            strScope = "ISINSCOPE ( '" + h.Table.Name + "'[" + l.Column.Name + "] )";
        } else {
            strScope = strScope + " + ISINSCOPE ( '" + h.Table.Name + "'[" + l.Column.Name + "] )";
        }
        iLevelCount = iLevelCount + 1;
    }
    
    string strDaxCode = @"// Levels: " + h.Levels.Count.ToString() + @"
// The previous line is auto-generated. Do not modify!
VAR _EntityShowRow =
    ( // BrowseDepth
        " + strScope + @"
    ) <= MAX( '" + h.Table.Name + @"'[Path Length] ) // RowDepth
VAR _Result =
    IF ( _EntityShowRow, SELECTEDMEASURE() )
RETURN
    _Result
    ";
// then modify the DAX code 
//   Interaction.MsgBox(ciHierachy.Name);  
   ciHierachy.Expression = strDaxCode;

// hide source columns of hierachy

}