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
exports.DeploymentFactory = void 0;
const taskparameters_1 = require("../taskparameters");
const BuiltInLinuxWebAppDeploymentProvider_1 = require("./BuiltInLinuxWebAppDeploymentProvider");
const WindowsWebAppZipDeployProvider_1 = require("./WindowsWebAppZipDeployProvider");
const WindowsWebAppRunFromZipProvider_1 = require("./WindowsWebAppRunFromZipProvider");
const ConsumptionWebAppDeploymentProvider_1 = require("./ConsumptionWebAppDeploymentProvider");
const tl = require("azure-pipelines-task-lib/task");
const packageUtility_1 = require("azure-pipelines-tasks-azurermdeploycommon/webdeployment-common/packageUtility");
const WindowsWebAppWarDeployProvider_1 = require("./WindowsWebAppWarDeployProvider");
class DeploymentFactory {
    constructor(taskParams) {
        this._taskParams = taskParams;
    }
    GetDeploymentProvider() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this._taskParams.isLinuxApp) {
                tl.debug("Depolyment started for linux app service");
                if (this._taskParams.isConsumption) {
                    return new ConsumptionWebAppDeploymentProvider_1.ConsumptionWebAppDeploymentProvider(this._taskParams);
                }
                else {
                    return new BuiltInLinuxWebAppDeploymentProvider_1.BuiltInLinuxWebAppDeploymentProvider(this._taskParams);
                }
            }
            else {
                tl.debug("Depolyment started for windows app service");
                return yield this._getWindowsDeploymentProvider();
            }
        });
    }
    _getWindowsDeploymentProvider() {
        return __awaiter(this, void 0, void 0, function* () {
            tl.debug("Package type of deployment is: " + this._taskParams.Package.getPackageType());
            switch (this._taskParams.Package.getPackageType()) {
                case packageUtility_1.PackageType.war:
                    return new WindowsWebAppWarDeployProvider_1.WindowsWebAppWarDeployProvider(this._taskParams);
                case packageUtility_1.PackageType.jar:
                    return new WindowsWebAppZipDeployProvider_1.WindowsWebAppZipDeployProvider(this._taskParams);
                default:
                    return yield this._getWindowsDeploymentProviderForZipAndFolderPackageType();
            }
        });
    }
    _getWindowsDeploymentProviderForZipAndFolderPackageType() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this._taskParams.DeploymentType != taskparameters_1.DeploymentType.auto) {
                return yield this._getUserSelectedDeploymentProviderForWindow();
            }
            else {
                var _isMSBuildPackage = yield this._taskParams.Package.isMSBuildPackage();
                if (_isMSBuildPackage) {
                    throw new Error(tl.loc('MsBuildPackageNotSupported', this._taskParams.Package.getPath()));
                }
                else {
                    return new WindowsWebAppRunFromZipProvider_1.WindowsWebAppRunFromZipProvider(this._taskParams);
                }
            }
        });
    }
    _getUserSelectedDeploymentProviderForWindow() {
        switch (this._taskParams.DeploymentType) {
            case taskparameters_1.DeploymentType.zipDeploy:
                return new WindowsWebAppZipDeployProvider_1.WindowsWebAppZipDeployProvider(this._taskParams);
            case taskparameters_1.DeploymentType.runFromPackage:
                return new WindowsWebAppRunFromZipProvider_1.WindowsWebAppRunFromZipProvider(this._taskParams);
        }
    }
}
exports.DeploymentFactory = DeploymentFactory;
