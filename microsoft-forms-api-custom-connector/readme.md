# Microsoft Forms Custom Connetor
**Work in progress!**

Microsoft forms has an API to get data about surveys and responses directly from Microsoft Forms. 
The primary intention of this API is to server Power Automate, but since the API is there, it can 
also be used to load data from Forms directly into Power BI. The only challenge is that the OAuth 
autentication workflow is not implemented for this API, because when being called from Power Automate 
or directly in the Web-Browser, after visiting the Forms web-app, then the authentication token comes
from the Power Automate environment rest. the web-browser.

In order to connect from Power BI to the Forms API, a custom connector must handle the OAuth 
authentication workflow and provide the API calls with the necessary authentication (bearer) token. 
This includes basically two parts:

- The Microsoft Forms custom connector
- An Azure App Registration for Microsoft Forms

If the custom connector shall be used in scheduled refresh scenarios, then the custom connector 
must be installed together with a Power BI On Premises Gateway Standard Edition. This can run on 
premises or in the cloud, directly on a physical machine or on a virtual machine, e.g. Azure VM. 
If you already have a gateway running, you can just add the custom connector .mez file there.

## [Microsoft Forms API Resources](https://forms.office.com/formapi/api/$metadata)

- [formsCore](https://forms.office.com/formapi/api/formsCore)
- [runtimeFormsCore](https://forms.office.com/formapi/api/runtimeFormsCore)
- [forms](https://forms.office.com/formapi/api/forms): List of all forms including their formid that are accessible for the requesting identity.
  - Example for a specific form (first GUID is tenant id): [https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')](https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u'))
- [runtimeForms](https://forms.office.com/formapi/api/runtimeForms)
- [analysisForms](https://forms.office.com/formapi/api/analysisForms)
- [sharedWithMeForms](https://forms.office.com/formapi/api/sharedWithMeForms): List of share with me forms.
- [groups](https://forms.office.com/formapi/api/groups): Groups are teams.
- [permissionTokens](https://forms.office.com/formapi/api/permissionTokens)
- [users](https://forms.office.com/formapi/api/users)
- [photos](https://forms.office.com/formapi/api/photos)
- [questions](https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')/questions): Question texts and ids.
- [responses](https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')/responses?$expand=comments&$top=1000&$skip=0): Responses for a form, in pages of max. 1000 rows.
  - Number of responses: [https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')/responses/$count](https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')/responses/$count)
  - Example from responses summary web page: [https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')?$select=DataClassificationLabel,background,cardProps,category,collectionId,createdBy,createdDate,defaultLanguage,description,descriptiveQuestions,distributionInfo,emailReceiptConsent,emailReceiptEnabled,fillOutRemainingTime,fillOutTimeLimit,flags,footerText,formsInsightsInfo,formsProRTDescription,formsProRTTitle,id,localeInfo,localeList,localeResources,localizedResources,logo,migrationWorkbookId,modifiedDate,onlineSafetyLevel,order,otherInfo,ownerId,ownerTenantId,permissionTokens,permissions,privacyUrl,progressBarEnabled,questions,reputationTier,responderPermissions,responses,rowCount,settings,smartConvertMetaData,softDeleted,startedDate,status,subTitle,teamsPollProperty,tenantSwitches,termsUrl,thankYouMessage,themeV2,title,trackingId,type,version,xlExportingTag,xlFileUnSynced,xlUnsyncedReason,xlWorkbookId,sdxWorkbookId&$expand=permissions,permissionTokens,questions($expand=choices)](https://forms.office.com/formapi/api/272c3ca3-ccc2-49e8-aa06-76c8fb318ac4/users/1f7eab7d-48ef-44e2-b3fb-ba0c6efde6bd/forms('ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u')?$select=DataClassificationLabel,background,cardProps,category,collectionId,createdBy,createdDate,defaultLanguage,description,descriptiveQuestions,distributionInfo,emailReceiptConsent,emailReceiptEnabled,fillOutRemainingTime,fillOutTimeLimit,flags,footerText,formsInsightsInfo,formsProRTDescription,formsProRTTitle,id,localeInfo,localeList,localeResources,localizedResources,logo,migrationWorkbookId,modifiedDate,onlineSafetyLevel,order,otherInfo,ownerId,ownerTenantId,permissionTokens,permissions,privacyUrl,progressBarEnabled,questions,reputationTier,responderPermissions,responses,rowCount,settings,smartConvertMetaData,softDeleted,startedDate,status,subTitle,teamsPollProperty,tenantSwitches,termsUrl,thankYouMessage,themeV2,title,trackingId,type,version,xlExportingTag,xlFileUnSynced,xlUnsyncedReason,xlWorkbookId,sdxWorkbookId&$expand=permissions,permissionTokens,questions($expand=choices))
- [userInfo](https://forms.office.com/formapi/api/userInfo): Info about the current user.
- [GetFormsTenantSettings](https://forms.office.com/formapi/api/GetFormsTenantSettings): Forms tenant settings.
- [GetCurrentUserPhotoValue](https://forms.office.com/formapi/api/GetCurrentUserPhotoValue): Metadata of the photo of the current user.
- [GetRespCounts](https://forms.office.com/formapi/api/GetRespCounts)
- [DownloadExcelFile.ashx](https://forms.office.com/formapi/DownloadExcelFile.ashx?formid=ozwsJ8LM6EmqBnbI-zGKxH2rfh_vSOJEs_u6DG795r1URVFGSUVEVFZHSlQ0M1lJQTRaTjdEM1pJNC4u&timezoneOffset=0&minResponseId=1&maxResponseId=1000): Returns an Excel-file with reponses. There is a maximum of 1000 rows returned per file. If the survey has more than 1000 rows, the connector needs to implement paging.

You can access these API resources directly from the web-browser, but you first must have logged in at the forms web-app at [https://forms.office.com/](https://forms.office.com/).

Further discussion: [https://techcommunity.microsoft.com/t5/microsoft-forms/api-to-access-ms-forms/m-p/1463830/page/2](https://techcommunity.microsoft.com/t5/microsoft-forms/api-to-access-ms-forms/m-p/1463830/page/2)
