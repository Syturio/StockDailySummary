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
exports.AzureRmWebAppDeploymentProvider = void 0;
const KuduServiceUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/KuduServiceUtility");
const azure_arm_app_service_1 = require("azure-pipelines-tasks-azurermdeploycommon/azure-arm-rest/azure-arm-app-service");
const AzureAppServiceUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/AzureAppServiceUtility");
const tl = require("azure-pipelines-task-lib/task");
const ParameterParser = require("azure-pipelines-tasks-azurermdeploycommon/operations/ParameterParserUtility");
const ReleaseAnnotationUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/operations/ReleaseAnnotationUtility");
const packageUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/packageUtility");
const Constants_1 = require("azure-pipelines-tasks-azurermdeploycommon/Constants");
class AzureRmWebAppDeploymentProvider {
    constructor(taskParams) {
        this.virtualApplicationPath = "";
        this.taskParams = taskParams;
        let packageArtifactAlias = packageUtility_1.PackageUtility.getArtifactAlias(this.taskParams.Package.getPath());
        tl.setVariable(Constants_1.AzureDeployPackageArtifactAlias, packageArtifactAlias);
    }
    PreDeploymentStep() {
        return __awaiter(this, void 0, void 0, function* () {
            this.appService = new azure_arm_app_service_1.AzureAppService(this.taskParams.azureEndpoint, this.taskParams.ResourceGroupName, this.taskParams.WebAppName, this.taskParams.SlotName, this.taskParams.WebAppKind);
            this.appServiceUtility = new AzureAppServiceUtility_1.AzureAppServiceUtility(this.appService);
            this.kuduService = yield this.appServiceUtility.getKuduService();
            this.kuduServiceUtility = new KuduServiceUtility_1.KuduServiceUtility(this.kuduService);
        });
    }
    DeployWebAppStep() {
        return __awaiter(this, void 0, void 0, function* () { });
    }
    UpdateDeploymentStatus(isDeploymentSuccess) {
        return __awaiter(this, void 0, void 0, function* () {
            yield ReleaseAnnotationUtility_1.addReleaseAnnotation(this.taskParams.azureEndpoint, this.appService, isDeploymentSuccess);
            if (this.kuduServiceUtility) {
                this.activeDeploymentID = yield this.kuduServiceUtility.updateDeploymentStatus(isDeploymentSuccess, null, { 'type': 'Deployment', slotName: this.appService.getSlot() });
                tl.debug('Active DeploymentId :' + this.activeDeploymentID);
            }
            let appServiceApplicationUrl = yield this.appServiceUtility.getApplicationURL();
            console.log(tl.loc('AppServiceApplicationURL', appServiceApplicationUrl));
            tl.setVariable('AppServiceApplicationUrl', appServiceApplicationUrl);
        });
    }
    PostDeploymentStep() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.taskParams.AppSettings) {
                var customApplicationSettings = ParameterParser.parse(this.taskParams.AppSettings);
                yield this.appServiceUtility.updateAndMonitorAppSettings(customApplicationSettings);
            }
            if (this.taskParams.ConfigurationSettings) {
                var customApplicationSettings = ParameterParser.parse(this.taskParams.ConfigurationSettings);
                yield this.appServiceUtility.updateConfigurationSettings(customApplicationSettings);
            }
            yield this.appServiceUtility.updateScmTypeAndConfigurationDetails();
        });
    }
}
exports.AzureRmWebAppDeploymentProvider = AzureRmWebAppDeploymentProvider;
