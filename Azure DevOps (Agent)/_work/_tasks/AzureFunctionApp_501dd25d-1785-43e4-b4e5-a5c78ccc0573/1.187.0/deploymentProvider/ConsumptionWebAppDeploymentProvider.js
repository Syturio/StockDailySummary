"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConsumptionWebAppDeploymentProvider = void 0;
const AzureRmWebAppDeploymentProvider_1 = require("./AzureRmWebAppDeploymentProvider");
const tl = require("azure-pipelines-task-lib/task");
const azure_arm_app_service_1 = require("azure-pipelines-tasks-azurermdeploycommon/azure-arm-rest/azure-arm-app-service");
const AzureAppServiceUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/AzureAppServiceUtility");
const packageUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/packageUtility");
const webClient_1 = require("azure-pipelines-tasks-azurermdeploycommon/azure-arm-rest/webClient");
const Q = require("q");
var webCommonUtility = require('azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/utility.js');
var zipUtility = require('azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/ziputility.js');
var azureStorage = require('azure-storage');
const ParameterParser = require("azure-pipelines-tasks-azurermdeploycommon/operations/ParameterParserUtility");
class ConsumptionWebAppDeploymentProvider extends AzureRmWebAppDeploymentProvider_1.AzureRmWebAppDeploymentProvider {
    PreDeploymentStep() {
        return __awaiter(this, void 0, void 0, function* () {
            this.appService = new azure_arm_app_service_1.AzureAppService(this.taskParams.azureEndpoint, this.taskParams.ResourceGroupName, this.taskParams.WebAppName, this.taskParams.SlotName, this.taskParams.WebAppKind, true);
            this.appServiceUtility = new AzureAppServiceUtility_1.AzureAppServiceUtility(this.appService);
        });
    }
    DeployWebAppStep() {
        return __awaiter(this, void 0, void 0, function* () {
            let storageDetails = yield this.findStorageAccount();
            let sasUrl = yield this.uploadPackage(storageDetails, this.taskParams.Package);
            let userDefinedAppSettings = this._getUserDefinedAppSettings();
            yield this.publishRunFromPackage(sasUrl, userDefinedAppSettings);
            yield this.PostDeploymentStep();
        });
    }
    findStorageAccount() {
        return __awaiter(this, void 0, void 0, function* () {
            let appSettings = yield this.appService.getApplicationSettings();
            var storageData = {};
            if (appSettings && appSettings.properties && appSettings.properties.AzureWebJobsStorage) {
                let webStorageSetting = appSettings.properties.AzureWebJobsStorage;
                let dictionary = getKeyValuePairs(webStorageSetting);
                tl.debug(`Storage Account is: ${dictionary["AccountName"]}`);
                storageData["AccountName"] = dictionary["AccountName"];
                storageData["AccountKey"] = dictionary["AccountKey"];
            }
            if (!storageData["AccountName"] || !storageData["AccountKey"]) {
                throw new Error(tl.loc('FailedToGetStorageAccountDetails'));
            }
            return storageData;
        });
    }
    uploadPackage(storageDetails, deployPackage) {
        return __awaiter(this, void 0, void 0, function* () {
            let defer = Q.defer();
            let storageAccount = storageDetails["AccountName"];
            let storageKey = storageDetails["AccountKey"];
            const blobService = azureStorage.createBlobService(storageAccount, storageKey);
            const containerName = 'azure-pipelines-deploy';
            const blobName = `package_${Date.now()}.zip`;
            let fileName;
            switch (deployPackage.getPackageType()) {
                case packageUtility_1.PackageType.folder:
                    let tempPackagePath = webCommonUtility.generateTemporaryFolderOrZipPath(tl.getVariable('AGENT.TEMPDIRECTORY'), false);
                    let archivedWebPackage;
                    try {
                        archivedWebPackage = yield zipUtility.archiveFolder(deployPackage.getPath(), "", tempPackagePath);
                    }
                    catch (error) {
                        defer.reject(error);
                    }
                    tl.debug("Compressed folder into zip " + archivedWebPackage);
                    fileName = archivedWebPackage;
                    break;
                case packageUtility_1.PackageType.zip:
                    fileName = deployPackage.getPath();
                    break;
                default:
                    throw new Error(tl.loc('Invalidwebapppackageorfolderpathprovided', deployPackage.getPath()));
            }
            blobService.createContainerIfNotExists(containerName, error => {
                if (error) {
                    defer.reject(error);
                }
                //upoading package
                blobService.createBlockBlobFromLocalFile(containerName, blobName, fileName, (error, result) => {
                    if (error) {
                        defer.reject(error);
                    }
                    //generating SAS URL
                    let startDate = new Date();
                    let expiryDate = new Date(startDate);
                    expiryDate.setFullYear(startDate.getUTCFullYear() + 1);
                    startDate.setMinutes(startDate.getMinutes() - 5);
                    let sharedAccessPolicy = {
                        AccessPolicy: {
                            Permissions: azureStorage.BlobUtilities.SharedAccessPermissions.READ,
                            Start: startDate,
                            Expiry: expiryDate
                        }
                    };
                    let token = blobService.generateSharedAccessSignature(containerName, blobName, sharedAccessPolicy);
                    let sasUrl = blobService.getUrl(containerName, blobName, token);
                    let index = sasUrl.indexOf("?");
                    let sasToken = sasUrl.substring(index + 1);
                    tl.setVariable('SAS_TOKEN', sasToken, true);
                    tl.debug(`SAS URL is: ${sasUrl}`);
                    defer.resolve(sasUrl);
                });
            });
            return defer.promise;
        });
    }
    publishRunFromPackage(sasUrl, additionalAppSettings) {
        return __awaiter(this, void 0, void 0, function* () {
            additionalAppSettings = !!additionalAppSettings ? additionalAppSettings : {};
            additionalAppSettings['WEBSITE_RUN_FROM_PACKAGE'] = sasUrl;
            console.log(tl.loc('UpdatingAppServiceApplicationSettings', JSON.stringify(additionalAppSettings)));
            yield this.appService.patchApplicationSettings(additionalAppSettings);
            console.log(tl.loc('UpdatedOnlyAppServiceApplicationSettings'));
            console.log(tl.loc('UpdatedRunFromPackageSettings', sasUrl));
            yield webClient_1.sleepFor(5);
            console.log(tl.loc('SyncingFunctionTriggers'));
            yield this.appService.syncFunctionTriggers();
            console.log(tl.loc('SyncFunctionTriggersSuccess'));
        });
    }
    PostDeploymentStep() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.taskParams.ConfigurationSettings) {
                var customApplicationSettings = ParameterParser.parse(this.taskParams.ConfigurationSettings);
                yield this.appServiceUtility.updateConfigurationSettings(customApplicationSettings);
            }
            yield this.appServiceUtility.updateScmTypeAndConfigurationDetails();
        });
    }
    _getUserDefinedAppSettings() {
        let userDefinedAppSettings = {};
        if (this.taskParams.AppSettings) {
            var customApplicationSettings = ParameterParser.parse(this.taskParams.AppSettings);
            for (var property in customApplicationSettings) {
                if (!!customApplicationSettings[property] && customApplicationSettings[property].value !== undefined) {
                    userDefinedAppSettings[property] = customApplicationSettings[property].value;
                }
            }
        }
        return userDefinedAppSettings;
    }
}
exports.ConsumptionWebAppDeploymentProvider = ConsumptionWebAppDeploymentProvider;
function getKeyValuePairs(webStorageSetting) {
    let keyValuePair = {};
    var splitted = webStorageSetting.split(";");
    for (var keyValue of splitted) {
        let indexOfSeparator = keyValue.indexOf("=");
        let key = keyValue.substring(0, indexOfSeparator);
        let value = keyValue.substring(indexOfSeparator + 1);
        keyValuePair[key] = value;
    }
    return keyValuePair;
}
