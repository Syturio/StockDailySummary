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
exports.run = void 0;
const auth = require("azure-pipelines-tasks-packaging-common/nuget/Authentication");
const commandHelper = require("azure-pipelines-tasks-packaging-common/nuget/CommandHelper");
const nutil = require("azure-pipelines-tasks-packaging-common/nuget/Utility");
const path = require("path");
const tl = require("azure-pipelines-task-lib/task");
const NuGetConfigHelper2_1 = require("azure-pipelines-tasks-packaging-common/nuget/NuGetConfigHelper2");
const ngRunner = require("azure-pipelines-tasks-packaging-common/nuget/NuGetToolRunner2");
const pkgLocationUtils = require("azure-pipelines-tasks-packaging-common/locationUtilities");
const util_1 = require("azure-pipelines-tasks-packaging-common/util");
function run() {
    return __awaiter(this, void 0, void 0, function* () {
        let packagingLocation;
        try {
            packagingLocation = yield pkgLocationUtils.getPackagingUris(pkgLocationUtils.ProtocolType.NuGet);
        }
        catch (error) {
            tl.debug('Unable to get packaging URIs');
            util_1.logError(error);
            throw error;
        }
        const buildIdentityDisplayName = null;
        const buildIdentityAccount = null;
        try {
            // Get list of files to publish
            const searchPatternInput = tl.getPathInput('searchPatternPush', true, false);
            const findOptions = {};
            const matchOptions = {};
            const searchPatterns = nutil.getPatternsArrayFromInput(searchPatternInput);
            const filesList = tl.findMatch(undefined, searchPatterns, findOptions, matchOptions);
            filesList.forEach(packageFile => {
                if (!tl.stats(packageFile).isFile()) {
                    throw new Error(tl.loc('Error_PushNotARegularFile', packageFile));
                }
            });
            if (filesList.length < 1) {
                tl.setResult(tl.TaskResult.Failed, tl.loc('Info_NoPackagesMatchedTheSearchPattern'));
                return;
            }
            // Get the info the type of feed
            let nugetFeedType = tl.getInput('nuGetFeedType') || 'internal';
            // Make sure the feed type is an expected one
            const normalizedNuGetFeedType = ['internal', 'external'].find(x => nugetFeedType.toUpperCase() === x.toUpperCase());
            if (!normalizedNuGetFeedType) {
                throw new Error(tl.loc('UnknownFeedType', nugetFeedType));
            }
            nugetFeedType = normalizedNuGetFeedType;
            const serviceUri = tl.getEndpointUrl('SYSTEMVSSCONNECTION', false);
            let urlPrefixes = packagingLocation.PackagingUris;
            tl.debug(`discovered URL prefixes: ${urlPrefixes}`);
            // Note to readers: This variable will be going away once we have a fix for the location service for
            // customers behind proxies
            const testPrefixes = tl.getVariable('DotNetCoreCLITask.ExtraUrlPrefixesForTesting');
            if (testPrefixes) {
                urlPrefixes = urlPrefixes.concat(testPrefixes.split(';'));
                tl.debug(`all URL prefixes: ${urlPrefixes}`);
            }
            // Setting up auth info
            const accessToken = pkgLocationUtils.getSystemAccessToken();
            const isInternalFeed = nugetFeedType === 'internal';
            const internalAuthInfo = new auth.InternalAuthInfo(urlPrefixes, accessToken, /*useCredProvider*/ null, true);
            let configFile = null;
            let apiKey;
            let credCleanup = () => { return; };
            // dotnet nuget push does not currently accept a --config-file parameter
            // so we are going to work around this by creating a temporary working directory for dotnet with
            // a nuget config file it will load by default.
            const tempNuGetConfigDirectory = path.join(NuGetConfigHelper2_1.NuGetConfigHelper2.getTempNuGetConfigBasePath(), 'NuGet_' + tl.getVariable('build.buildId'));
            const tempNuGetPath = path.join(tempNuGetConfigDirectory, 'nuget.config');
            tl.mkdirP(tempNuGetConfigDirectory);
            let feedUri = undefined;
            let authInfo;
            let nuGetConfigHelper;
            if (isInternalFeed) {
                authInfo = new auth.NuGetExtendedAuthInfo(internalAuthInfo);
                nuGetConfigHelper = new NuGetConfigHelper2_1.NuGetConfigHelper2(null, null, /* nugetConfigPath */ authInfo, { credProviderFolder: null, extensionsDisabled: true }, tempNuGetPath, false /* useNugetToModifyConfigFile */);
                const feed = util_1.getProjectAndFeedIdFromInputParam('feedPublish');
                feedUri = yield nutil.getNuGetFeedRegistryUrl(packagingLocation.DefaultPackagingUri, feed.feedId, feed.projectId, null, accessToken, /* useSession */ true);
                nuGetConfigHelper.addSourcesToTempNuGetConfig([{ feedName: feed.feedId, feedUri: feedUri, isInternal: true }]);
                configFile = nuGetConfigHelper.tempNugetConfigPath;
                credCleanup = () => { tl.rmRF(tempNuGetConfigDirectory); };
                apiKey = 'VSTS';
            }
            else {
                const externalAuthArr = commandHelper.GetExternalAuthInfoArray('externalEndpoint');
                authInfo = new auth.NuGetExtendedAuthInfo(internalAuthInfo, externalAuthArr);
                nuGetConfigHelper = new NuGetConfigHelper2_1.NuGetConfigHelper2(null, null, /* nugetConfigPath */ authInfo, { credProviderFolder: null, extensionsDisabled: true }, tempNuGetPath, false /* useNugetToModifyConfigFile */);
                const externalAuth = externalAuthArr[0];
                if (!externalAuth) {
                    tl.setResult(tl.TaskResult.Failed, tl.loc('Error_NoSourceSpecifiedForPush'));
                    return;
                }
                nuGetConfigHelper.addSourcesToTempNuGetConfig([externalAuth.packageSource]);
                feedUri = externalAuth.packageSource.feedUri;
                configFile = nuGetConfigHelper.tempNugetConfigPath;
                credCleanup = () => { tl.rmRF(tempNuGetConfigDirectory); };
                const authType = externalAuth.authType;
                switch (authType) {
                    case (auth.ExternalAuthType.UsernamePassword):
                    case (auth.ExternalAuthType.Token):
                        apiKey = 'RequiredApiKey';
                        break;
                    case (auth.ExternalAuthType.ApiKey):
                        const apiKeyAuthInfo = externalAuth;
                        apiKey = apiKeyAuthInfo.apiKey;
                        break;
                    default:
                        break;
                }
            }
            // Setting creds in the temp NuGet.config if needed
            nuGetConfigHelper.setAuthForSourcesInTempNuGetConfig();
            const dotnetPath = tl.which('dotnet', true);
            try {
                for (const packageFile of filesList) {
                    yield dotNetNuGetPushAsync(dotnetPath, packageFile, feedUri, apiKey, configFile, tempNuGetConfigDirectory);
                }
            }
            finally {
                credCleanup();
            }
            tl.setResult(tl.TaskResult.Succeeded, tl.loc('PackagesPublishedSuccessfully'));
        }
        catch (err) {
            tl.error(err);
            if (buildIdentityDisplayName || buildIdentityAccount) {
                tl.warning(tl.loc('BuildIdentityPermissionsHint', buildIdentityDisplayName, buildIdentityAccount));
            }
            tl.setResult(tl.TaskResult.Failed, tl.loc('PackagesFailedToPublish'));
        }
    });
}
exports.run = run;
function dotNetNuGetPushAsync(dotnetPath, packageFile, feedUri, apiKey, configFile, workingDirectory) {
    const dotnet = tl.tool(dotnetPath);
    dotnet.arg('nuget');
    dotnet.arg('push');
    dotnet.arg(packageFile);
    dotnet.arg('--source');
    dotnet.arg(feedUri);
    dotnet.arg('--api-key');
    dotnet.arg(apiKey);
    // dotnet.exe v1 and v2 do not accept the --verbosity parameter for the "nuget push"" command, although it does for other commands
    const envWithProxy = ngRunner.setNuGetProxyEnvironment(process.env, /*configFile*/ null, feedUri);
    return dotnet.exec({ cwd: workingDirectory, env: envWithProxy });
}
