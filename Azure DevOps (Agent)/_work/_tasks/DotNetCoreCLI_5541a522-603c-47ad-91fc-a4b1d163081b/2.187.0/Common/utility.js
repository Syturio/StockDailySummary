"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProjectFiles = void 0;
const tl = require("azure-pipelines-task-lib/task");
function getProjectFiles(projectPattern) {
    if (projectPattern.length == 0) {
        return [""];
    }
    var projectFiles = tl.findMatch(tl.getVariable("System.DefaultWorkingDirectory") || process.cwd(), projectPattern);
    if (!projectFiles || !projectFiles.length) {
        return [];
    }
    return projectFiles;
}
exports.getProjectFiles = getProjectFiles;
