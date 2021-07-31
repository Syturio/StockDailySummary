"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reportArchivePlan = void 0;
const tl = require("azure-pipelines-task-lib/task");
function reportArchivePlan(files, max = 10) {
    var plan = [];
    plan.push(tl.loc('FoundNFiles', files.length));
    if (files.length > 0) {
        var limit = Math.min(files.length, max);
        for (var i = 0; i < limit; i++) {
            plan.push(tl.loc('ArchivingFile', files[i]));
        }
        if (files.length > max) {
            plan.push(tl.loc('MoreFiles', files.length - max));
        }
    }
    return plan;
}
exports.reportArchivePlan = reportArchivePlan;
