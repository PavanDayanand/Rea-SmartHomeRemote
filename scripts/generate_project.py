#!/usr/bin/env python3
"""Create the Xcode project without requiring Homebrew or third-party packages.

Run this again only after adding/removing Swift files. Open Breeze.xcodeproj
for normal learning, editing, building, and running.
"""
import hashlib
import json
import plistlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
# Apple Personal Teams cannot provision Access Wi-Fi Information.
# Use this option only with a team that supports the capability, then run pod install.
enable_wifi_info = "--enable-wifi-info" in sys.argv
PROJECT = ROOT / "Breeze.xcodeproj"
PROJECT.mkdir(exist_ok=True)

# Keep the team you selected in Xcode when refreshing the file list.
existing_teams = {}
project_file = PROJECT / "project.pbxproj"
if project_file.exists():
    result = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(project_file)],
        capture_output=True, text=True, check=True
    )
    for key, value in json.loads(result.stdout)["objects"].items():
        team = value.get("buildSettings", {}).get("DEVELOPMENT_TEAM")
        if team:
            existing_teams[key] = team


def identifier(name):
    return hashlib.sha1(name.encode()).hexdigest()[:24].upper()


def quote(value):
    return json.dumps(str(value))


objects = []


def add(name, contents):
    key = identifier(name)
    objects.append(f"\t\t{key} = {{ {contents} }};")
    return key


def settings(values):
    return " ".join(f"{key} = {quote(value)};" for key, value in values.items())


def configuration_list(name, values):
    configs = []
    for mode in ["Debug", "Release"]:
        current = dict(values)
        saved_team = existing_teams.get(identifier(f"{name}-{mode}"))
        if saved_team:
            current["DEVELOPMENT_TEAM"] = saved_team
        current["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone" if mode == "Debug" else "-O"
        if mode == "Debug":
            current["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "DEBUG BREEZE_APP" if name == "Breeze" else "DEBUG"
            current["ENABLE_TESTABILITY"] = "YES"
        elif name == "Breeze":
            current["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "BREEZE_APP"
        configs.append(add(f"{name}-{mode}", f"isa = XCBuildConfiguration; name = {mode}; buildSettings = {{ {settings(current)} }};"))
    return add(f"{name}-configs", f"isa = XCConfigurationList; buildConfigurations = ({','.join(configs)},); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;")


# Legacy demo sources are retained for learning, but never compiled or exposed.
def is_live_source(path):
    relative = path.relative_to(ROOT).as_posix()
    demo_intents = {"FanEntity.swift", "FanQuery.swift", "FanMode+AppEnum.swift",
        "SetFanPowerIntent.swift", "SetFanSpeedIntent.swift", "SetFanLightIntent.swift",
        "SetFanModeIntent.swift", "SetFanTimerIntent.swift"}
    demo_widgets = {"BreezeFanWidget.swift", "FanWidgetView.swift", "FanWidgetProvider.swift",
        "FanWidgetEntry.swift", "FanWidgetConfiguration.swift"}
    return not (("/Intents/" in relative and path.name in demo_intents)
        or (relative.startswith("BreezeWidgets/") and path.name in demo_widgets)
        or any(relative.startswith("Breeze/Features/" + folder + "/") for folder in ["Home", "Controls", "About"]))

app_files = sorted(p for p in ROOT.glob("Breeze/**/*.swift") if is_live_source(p))
widget_files = sorted(p for p in list(ROOT.glob("Breeze/Shared/**/*.swift")) + list(ROOT.glob("BreezeWidgets/*.swift")) if is_live_source(p))
test_files = sorted(ROOT.glob("BreezeUITests/*.swift"))
all_files = sorted(set(app_files + widget_files + test_files))
file_ids = {}
for file in all_files:
    path = file.relative_to(ROOT).as_posix()
    file_ids[path] = add(path, f"isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {quote(path)}; sourceTree = SOURCE_ROOT;")

assets = add("assets", 'isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Breeze/Assets.xcassets; sourceTree = SOURCE_ROOT;')
secrets = add("tuya-secrets", 'isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Configuration/TuyaSecrets.plist; sourceTree = SOURCE_ROOT;')
products = {}
for name, extension, filetype in [("Breeze", "app", "wrapper.application"), ("BreezeWidgets", "appex", "wrapper.app-extension"), ("BreezeUITests", "xctest", "wrapper.cfbundle")]:
    products[name] = add(name + "-product", f"isa = PBXFileReference; explicitFileType = {filetype}; path = {name}.{extension}; sourceTree = BUILT_PRODUCTS_DIR;")

product_group = add("products", f"isa = PBXGroup; name = Products; children = ({','.join(products.values())},); sourceTree = \"<group>\";")
source_groups = []
for name, prefix in [("App", "Breeze/App/"), ("Connectivity", "Breeze/Connectivity/"), ("Fan models", "Breeze/Shared/Models/"), ("Saving settings", "Breeze/Shared/Storage/"), ("Siri actions", "Breeze/Shared/Intents/"), ("Screens", "Breeze/Features/"), ("Widgets", "BreezeWidgets/"), ("UI tests", "BreezeUITests/")]:
    children = [key for path, key in file_ids.items() if path.startswith(prefix)]
    source_groups.append(add("group-" + name, f"isa = PBXGroup; name = {quote(name)}; children = ({','.join(children)},); sourceTree = \"<group>\";"))
main_group = add("main-group", f"isa = PBXGroup; children = ({','.join(source_groups + [assets, secrets, product_group])},); sourceTree = \"<group>\";")

project_configs = configuration_list("Project", {
    "SDKROOT": "iphoneos", "IPHONEOS_DEPLOYMENT_TARGET": "27.0",
    "SWIFT_VERSION": "6.0", "CLANG_ENABLE_MODULES": "YES",
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES", "DEBUG_INFORMATION_FORMAT": "dwarf",
})


def source_phase(name, files):
    builds = []
    for file in files:
        path = file.relative_to(ROOT).as_posix()
        builds.append(add(name + "-" + path, f"isa = PBXBuildFile; fileRef = {file_ids[path]};"))
    return add(name + "-sources", f"isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({','.join(builds)},); runOnlyForDeploymentPostprocessing = 0;")


def dependency(source, target):
    proxy = add(source + "-proxy-" + target, f"isa = PBXContainerItemProxy; containerPortal = {identifier('project')}; proxyType = 1; remoteGlobalIDString = {identifier(target + '-target')}; remoteInfo = {target};")
    return add(source + "-depends-" + target, f"isa = PBXTargetDependency; target = {identifier(target + '-target')}; targetProxy = {proxy};")


for name, files, product_type in [("Breeze", app_files, "application"), ("BreezeWidgets", widget_files, "app-extension"), ("BreezeUITests", test_files, "bundle.ui-testing")]:
    phases = [source_phase(name, files)]
    phases.append(add(name + "-frameworks", "isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;"))
    resource_files = []
    if name == "Breeze":
        resource_files.append(add("app-assets", f"isa = PBXBuildFile; fileRef = {assets};"))
        resource_files.append(add("app-secrets", f"isa = PBXBuildFile; fileRef = {secrets};"))
    phases.append(add(name + "-resources", f"isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({','.join(resource_files)}); runOnlyForDeploymentPostprocessing = 0;"))
    dependencies = []
    if name == "Breeze":
        embedded = add("embedded-widget", f"isa = PBXBuildFile; fileRef = {products['BreezeWidgets']}; settings = {{ ATTRIBUTES = (RemoveHeadersOnCopy,); }};")
        phases.append(add("embed-extensions", f'isa = PBXCopyFilesBuildPhase; buildActionMask = 2147483647; dstPath = ""; dstSubfolderSpec = 13; files = ({embedded},); name = "Embed App Extensions"; runOnlyForDeploymentPostprocessing = 0;'))
        dependencies.append(dependency(name, "BreezeWidgets"))
    if name == "BreezeUITests":
        dependencies.append(dependency(name, "Breeze"))
    values = {
        "PRODUCT_NAME": "$(TARGET_NAME)", "PRODUCT_BUNDLE_IDENTIFIER": "com.pavand." + name.lower(),
        "CODE_SIGN_STYLE": "Automatic", "TARGETED_DEVICE_FAMILY": "1,2",
        "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator", "SUPPORTS_MACCATALYST": "NO",
        "CURRENT_PROJECT_VERSION": "1", "MARKETING_VERSION": "0.1.0",
        "GENERATE_INFOPLIST_FILE": "YES", "SWIFT_EMIT_LOC_STRINGS": "YES",
    }
    if name != "BreezeUITests":
        values.update({"INFOPLIST_FILE": f"Configuration/{name}-Info.plist", "CODE_SIGN_ENTITLEMENTS": "Configuration/Breeze.entitlements"})
    if name == "Breeze":
        values.update({"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon", "INFOPLIST_KEY_UILaunchScreen_Generation": "YES", "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES", "ENABLE_USER_SCRIPT_SANDBOXING": "NO"})
    if name == "BreezeWidgets":
        values.update({"APPLICATION_EXTENSION_API_ONLY": "YES", "SKIP_INSTALL": "YES", "PRODUCT_BUNDLE_IDENTIFIER": "com.pavand.breeze.widgets", "CODE_SIGN_ENTITLEMENTS": "Configuration/BreezeWidgets.entitlements"})
    if name == "BreezeUITests":
        values["TEST_TARGET_NAME"] = "Breeze"
    configs = configuration_list(name, values)
    add(name + "-target", f"isa = PBXNativeTarget; buildConfigurationList = {configs}; buildPhases = ({','.join(phases)},); buildRules = (); dependencies = ({','.join(dependencies)}); name = {name}; productName = {name}; productReference = {products[name]}; productType = com.apple.product-type.{product_type};")

targets = [identifier(name + "-target") for name in ["Breeze", "BreezeWidgets", "BreezeUITests"]]
add("project", f"isa = PBXProject; attributes = {{ BuildIndependentTargetsInParallel = YES; LastUpgradeCheck = 2720; }}; buildConfigurationList = {project_configs}; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en,Base); mainGroup = {main_group}; productRefGroup = {product_group}; projectDirPath = \"\"; projectRoot = \"\"; targets = ({','.join(targets)},);")
(PROJECT / "project.pbxproj").write_text("// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n" + "\n".join(objects) + f"\n}}; rootObject = {identifier('project')}; }}\n")

scheme_dir = PROJECT / "xcshareddata/xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)


def reference(name, extension):
    return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{identifier(name + "-target")}" BuildableName="{name}.{extension}" BlueprintName="{name}" ReferencedContainer="container:Breeze.xcodeproj"/>'


(scheme_dir / "Breeze.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2720" version="1.7">
  <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
    <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{reference("Breeze", "app")}</BuildActionEntry>
  </BuildActionEntries></BuildAction>
  <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables>
    <TestableReference skipped="NO">{reference("BreezeUITests", "xctest")}</TestableReference>
  </Testables></TestAction>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference("Breeze", "app")}</BuildableProductRunnable></LaunchAction>
  <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference("Breeze", "app")}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>''')

config = ROOT / "Configuration"
config.mkdir(exist_ok=True)
plists = {
    "Breeze-Info.plist": {
        "CFBundleDisplayName": "Breeze",
        "BreezeCanReadWiFi": enable_wifi_info,
        "BreezeCanUseEZ": False,
        "NSLocalNetworkUsageDescription": "Breeze connects your fan to Wi-Fi and sends device commands on your home network.",
        "NSBluetoothAlwaysUsageDescription": "Breeze’s device SDK can discover compatible fans nearby during setup.",
        "NSLocationWhenInUseUsageDescription": "Breeze uses this permission to read your current Wi-Fi name during fan setup in eligible builds. Breeze does not request your coordinates.",
        "CFBundleURLTypes": [{"CFBundleURLName": "com.pavand.breeze", "CFBundleURLSchemes": ["breeze"]}],
        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"],
    },
    "BreezeWidgets-Info.plist": {"CFBundleDisplayName": "Breeze", "NSExtension": {"NSExtensionPointIdentifier": "com.apple.widgetkit-extension"}},
    "Breeze.entitlements": {"com.apple.security.application-groups": ["group.com.pavand.breeze"]},
    "BreezeWidgets.entitlements": {"com.apple.security.application-groups": ["group.com.pavand.breeze"]},
}
if enable_wifi_info:
    plists["Breeze.entitlements"]["com.apple.developer.networking.wifi-info"] = True
for name, contents in plists.items():
    (config / name).write_bytes(plistlib.dumps(contents))
print(f"Generated {PROJECT} with {len(all_files)} Swift files and three targets.")
