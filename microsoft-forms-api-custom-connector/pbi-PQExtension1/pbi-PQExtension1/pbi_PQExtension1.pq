/////////////////////////////////////////////////////////////
// 
// load list of forms from Microsoft Forms API
//
// Requires Azure App Registration for authentication to work:
// Register URL https://forms.office.com and 
// Add Microsoft Forms API permissions
// 
/////////////////////////////////////////////////////////////

// This file contains your Data Connector logic
section pbi_PQExtension1;

//
// OAuth configuration settings
//

client_id = Text.FromBinary(Extension.Contents("AppID.txt"));  

client_secret = Text.FromBinary(Extension.Contents("ClientSecret.txt"));

redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";
token_uri = "https://login.windows.net/common/oauth2/token";
authorize_uri = "https://login.windows.net/common/oauth2/authorize";
logout_uri = "https://login.microsoftonline.com/logout.srf";
resourceUri = "https://forms.office.com"; // /formapi/api"; // resourceUri = "https://analysis.windows.net/powerbi/api";

windowWidth = 720;
windowHeight = 1024;

[DataSource.Kind="pbi_PQExtension1", Publish="pbi_PQExtension1.UI"]
shared pbi_PQExtension1.Navigation = () as table =>
let
        objects = #table(
            {"Name","Key","Data","ItemKind","ItemName","IsLeaf"},{
            {Extension.LoadString("Forms"),"Forms",pbi_PQExtension1.GetForms(),"Table","Table",true}
        }),
        NavTable = Table.ToNavigationTable(objects,{"Key"},"Name","Data","ItemKind","ItemName","IsLeaf")
in
        NavTable;

pbi_PQExtension1 = [
TestConnection = (dataSourcePath) =>  { "pbi_PQExtension1.Navigation"},
    Authentication = [
       Aad =  [AuthorizationUri = authorize_uri,
            Resource = resourceUri]            
    ],
    Label = Extension.LoadString("DataSourceLabel") 
];

[DataSource.Kind="pbi_PQExtension1"]
shared	pbi_PQExtension1.GetForms = () =>
let
	source = Json.Document(Web.Contents("https://forms.office.com/formapi/api/forms", [Headers = [#"Content-type" = "application/json"]])),
    #"Table from JSON" = Table.FromRecords({source}),
    FormsList = #"Table from JSON"[value]{0},
//    FormsData = source[Data],
//    FormsDrilldown = FormsData{0},
//    FormsList = FormsDrilldown[value],
    #"List to table" = Table.FromList(FormsList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Record to columns" = Table.ExpandRecordColumn(#"List to table", "Column1", {"id", "title", "modifiedDate", "createdDate", "version", "ownerId", "ownerTenantId", "settings", "softDeleted", "thankYouMessage", "flags", "emailReceiptEnabled", "type", "defaultLanguage", "dataClassificationLevel", "formsProRTTitle", "formsProRTDescription", "meetingId", "formsInsightsInfo", "responseThresholdCount", "inviteExpiryDays", "collectionId", "fillOutTimeLimit", "TenantSwitches", "PrivacyUrl", "description", "onlineSafetyLevel", "reputationTier", "tableId", "otherInfo", "status", "category", "predefinedResponses", "fillOutRemainingTime", "timedFormStartTime", "distributionInfo", "createdBy", "XlFileUnSynced", "mfpBranchingData", "rowCount@odata.type", "rowCount", "progressBarEnabled", "trackingId", "themeV2", "subTitle", "localeList", "logo", "header", "background", "FileUploadFormInfo"}, {"id", "title", "modifiedDate", "createdDate", "version", "ownerId", "ownerTenantId", "settings", "softDeleted", "thankYouMessage", "flags", "emailReceiptEnabled", "type", "defaultLanguage", "dataClassificationLevel", "formsProRTTitle", "formsProRTDescription", "meetingId", "formsInsightsInfo", "responseThresholdCount", "inviteExpiryDays", "collectionId", "fillOutTimeLimit", "TenantSwitches", "PrivacyUrl", "description", "onlineSafetyLevel", "reputationTier", "tableId", "otherInfo", "status", "category", "predefinedResponses", "fillOutRemainingTime", "timedFormStartTime", "distributionInfo", "createdBy", "XlFileUnSynced", "mfpBranchingData", "rowCount@odata.type", "rowCount", "progressBarEnabled", "trackingId", "themeV2", "subTitle", "localeList", "logo", "header", "background", "FileUploadFormInfo"}),
    #"Set data types" = Table.TransformColumnTypes(#"Record to columns",{{"rowCount", Int64.Type}, {"rowCount@odata.type", type text}, {"id", type text}, {"title", type text}, {"modifiedDate", type datetimezone}, {"createdDate", type datetimezone}, {"version", type text}, {"ownerId", type text}, {"ownerTenantId", type text}, {"settings", type text}, {"softDeleted", Int64.Type}, {"thankYouMessage", type text}, {"flags", Int64.Type}, {"createdBy", type text}, {"timedFormStartTime", type datetimezone}, {"fillOutRemainingTime", Int64.Type}, {"status", type text}, {"otherInfo", type text}, {"tableId", type text}, {"reputationTier", Int64.Type}, {"onlineSafetyLevel", Int64.Type}, {"description", type text}, {"subTitle", type text}, {"themeV2", type text}, {"trackingId", type text}, {"type", type text}, {"defaultLanguage", type text}, {"formsProRTTitle", type text}, {"formsProRTDescription", type text}, {"fillOutTimeLimit", Int64.Type}, {"TenantSwitches", Int64.Type}, {"PrivacyUrl", type text}}),
    #"Set boolean progressBarEnabled" = Table.TransformColumnTypes(#"Set data types", {{"progressBarEnabled", type logical}}, "en-US"),
    #"Set boolean XlFileUnSynced" = Table.TransformColumnTypes(#"Set boolean progressBarEnabled", {{"XlFileUnSynced", type logical}}, "en-US"),
    #"Remove time zone information" = Table.TransformColumnTypes(#"Set boolean XlFileUnSynced",{{"timedFormStartTime", type datetime}, {"modifiedDate", type datetime}, {"createdDate", type datetime}})
in
    #"Remove time zone information";

//
// UI Export definition
//
pbi_PQExtension1.UI = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    SourceImage = pbi_PQExtension1.Icons ,
    SourceTypeImage = pbi_PQExtension1.Icons 
];

pbi_PQExtension1.Icons = [
    Icon16 = { Extension.Contents("pbi_PQExtension116.png"), Extension.Contents("pbi_PQExtension120.png"), Extension.Contents("pbi_PQExtension124.png"), Extension.Contents("pbi_PQExtension132.png") },
    Icon32 = { Extension.Contents("pbi_PQExtension132.png"), Extension.Contents("pbi_PQExtension140.png"), Extension.Contents("pbi_PQExtension148.png"), Extension.Contents("pbi_PQExtension164.png") }
];

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;

Table.ForceToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;
