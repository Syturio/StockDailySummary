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
exports.WindowsWebAppRunFromZipProvider = void 0;
const AzureRmWebAppDeploymentProvider_1 = require("./AzureRmWebAppDeploymentProvider");
const tl = require("azure-pipelines-task-lib/task");
const ParameterParser = require("azure-pipelines-tasks-azurermdeploycommon/operations/ParameterParserUtility");
const taskparameters_1 = require("../taskparameters");
const packageUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/packageUtility");
const ReleaseAnnotationUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/ReleaseAnnotationUtility");
const FileTransformsUtility_js_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/FileTransformsUtility.js");
const oldRunFromZipAppSetting = '-WEBSITE_RUN_FROM_ZIP';
const runFromZipAppSetting = '-WEBSITE_RUN_FROM_PACKAGE 1';
var deployUtility = require('azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/utility.js');
var zipUtility = require('azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/ziputility.js');
class WindowsWebAppRunFromZipProvider extends AzureRmWebAppDeploymentProvider_1.AzureRmWebAppDeploymentProvider {
    DeployWebAppStep() {
        return __awaiter(this, void 0, void 0, function* () {
            let deploymentMethodtelemetry = '{"deploymentMethod":"Run from Package"}';
            console.log("##vso[telemetry.publish area=TaskDeploymentMethod;feature=AzureWebAppDeployment]" + deploymentMethodtelemetry);
            var webPackage = yield FileTransformsUtility_js_1.FileTransformsUtility.applyTransformations(this.taskParams.Package.getPath(), this.taskParams.WebConfigParameters, this.taskParams.Package.getPackageType());
            if (this.taskParams.DeploymentType === taskparameters_1.DeploymentType.runFromPackage) {
                var _isMSBuildPackage = yield this.taskParams.Package.isMSBuildPackage();
                if (_isMSBuildPackage) {
                    throw Error(tl.loc("Publishusingzipdeploynotsupportedformsbuildpackage"));
                }
                else if (this.taskParams.Package.getPackageType() === packageUtility_1.PackageType.war) {
                    throw Error(tl.loc("Publishusingzipdeploydoesnotsupportwarfile"));
                }
            }
            if (tl.stats(webPackage).isDirectory()) {
                let tempPackagePath = deployUtility.generateTemporaryFolderOrZipPath(tl.getVariable('AGENT.TEMPDIRECTORY'), false);
                webPackage = yield zipUtility.archiveFolder(webPackage, "", tempPackagePath);
                tl.debug("Compressed folder into zip " + webPackage);
            }
            tl.debug("Initiated deployment via kudu service for webapp package : ");
            var addCustomApplicationSetting = ParameterParser.parse(runFromZipAppSetting);
            var deleteCustomApplicationSetting = ParameterParser.parse(oldRunFromZipAppSetting);
            var isNewValueUpdated = yield this.appServiceUtility.updateAndMonitorAppSettings(addCustomApplicationSetting, deleteCustomApplicationSetting);
            if (!isNewValueUpdated) {
                yield this.kuduServiceUtility.warmpUp();
            }
            yield this.kuduServiceUtility.deployUsingRunFromZip(webPackage, { slotName: this.appService.getSlot() });
            yield this.PostDeploymentStep();
        });
    }
    UpdateDeploymentStatus(isDeploymentSuccess) {
        return __awaiter(this, void 0, void 0, function* () {
            yield ReleaseAnnotationUtility_1.addReleaseAnnotation(this.taskParams.azureEndpoint, this.appService, isDeploymentSuccess);
            let appServiceApplicationUrl = yield this.appServiceUtility.getApplicationURL();
            console.log(tl.loc('AppServiceApplicationURL', appServiceApplicationUrl));
            tl.setVariable('AppServiceApplicationUrl', appServiceApplicationUrl);
        });
    }
}
exports.WindowsWebAppRunFromZipProvider = WindowsWebAppRunFromZipProvider;
