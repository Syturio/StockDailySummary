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
const tl = require("azure-pipelines-task-lib/task");
const path = require("path");
const taskparameters_1 = require("./taskparameters");
const DeploymentFactory_1 = require("./deploymentProvider/DeploymentFactory");
const Endpoint = require("azure-pipelines-tasks-azurermdeploycommon/azure-arm-rest/azure-arm-endpoint");
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        let isDeploymentSuccess = true;
        try {
            tl.setResourcePath(path.join(__dirname, 'task.json'));
            tl.setResourcePath(path.join(__dirname, 'node_modules/azure-pipelines-tasks-azurermdeploycommon/module.json'));
            var taskParams = yield taskparameters_1.TaskParametersUtility.getParameters();
            var deploymentFactory = new DeploymentFactory_1.DeploymentFactory(taskParams);
            var deploymentProvider = yield deploymentFactory.GetDeploymentProvider();
            tl.debug("Predeployment Step Started");
            yield deploymentProvider.PreDeploymentStep();
            tl.debug("Deployment Step Started");
            yield deploymentProvider.DeployWebAppStep();
        }
        catch (error) {
            tl.debug("Deployment Failed with Error: " + error);
            isDeploymentSuccess = false;
            tl.setResult(tl.TaskResult.Failed, error);
        }
        finally {
            if (deploymentProvider != null) {
                yield deploymentProvider.UpdateDeploymentStatus(isDeploymentSuccess);
            }
            Endpoint.dispose();
            tl.debug(isDeploymentSuccess ? "Deployment Succeded" : "Deployment failed");
        }
    });
}
main();
