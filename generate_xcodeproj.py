#!/usr/bin/env python3
import os
import hashlib
import json

def gen_id(name: str) -> str:
    return hashlib.md5(name.encode('utf-8')).hexdigest()[:24].upper()

project_dir = "/Users/alan/Documents/AI/ipad/StillFantasyiPad"
sources_dir = os.path.join(project_dir, "Sources/StillFantasyiPad")

# Find all swift files
swift_files = []
for root, dirs, files in os.walk(sources_dir):
    for f in sorted(files):
        if f.endswith(".swift"):
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, project_dir)
            swift_files.append((f, rel_path))

print(f"Found {len(swift_files)} swift files:")
for f, r in swift_files:
    print(f"  - {f} ({r})")

# IDs
proj_id = gen_id("PROJECT_ROOT")
main_group_id = gen_id("MAIN_GROUP")
products_group_id = gen_id("PRODUCTS_GROUP")
sources_group_id = gen_id("SOURCES_GROUP")
resources_group_id = gen_id("RESOURCES_GROUP")
target_id = gen_id("TARGET_StillFantasyiPad")
app_product_id = gen_id("PRODUCT_APP")

sources_phase_id = gen_id("PHASE_SOURCES")
frameworks_phase_id = gen_id("PHASE_FRAMEWORKS")
resources_phase_id = gen_id("PHASE_RESOURCES")

proj_cfg_list_id = gen_id("CFG_LIST_PROJ")
proj_debug_cfg_id = gen_id("CFG_PROJ_DEBUG")
proj_release_cfg_id = gen_id("CFG_PROJ_RELEASE")

target_cfg_list_id = gen_id("CFG_LIST_TARGET")
target_debug_cfg_id = gen_id("CFG_TARGET_DEBUG")
target_release_cfg_id = gen_id("CFG_TARGET_RELEASE")

# Generate file refs and build files
pbx_build_files = []
pbx_file_refs = []
sources_build_file_ids = []
sources_group_children = []

for fname, rel_path in swift_files:
    file_ref_id = gen_id("FILEREF_" + rel_path)
    build_file_id = gen_id("BUILDFILE_" + rel_path)
    
    pbx_build_files.append(f'\t\t{build_file_id} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {fname} */; }};')
    pbx_file_refs.append(f'\t\t{file_ref_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{rel_path}"; sourceTree = "<group>"; }};')
    sources_build_file_ids.append(f'\t\t\t\t{build_file_id} /* {fname} in Sources */,')
    sources_group_children.append(f'\t\t\t\t{file_ref_id} /* {fname} */,')

# Resources ref
resources_ref_id = gen_id("FILEREF_Resources")
resources_build_id = gen_id("BUILDFILE_Resources")
pbx_file_refs.append(f'\t\t{resources_ref_id} /* Resources */ = {{isa = PBXFileReference; lastKnownFileType = folder; path = "Resources"; sourceTree = "<group>"; }};')
pbx_build_files.append(f'\t\t{resources_build_id} /* Resources in Resources */ = {{isa = PBXBuildFile; fileRef = {resources_ref_id} /* Resources */; }};')

# Product ref
pbx_file_refs.append(f'\t\t{app_product_id} /* StillFantasyiPad.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "StillFantasyiPad.app"; sourceTree = BUILT_PRODUCTS_DIR; }};')

build_files_str = "\n".join(pbx_build_files)
file_refs_str = "\n".join(pbx_file_refs)
sources_phase_entries = "\n".join(sources_build_file_ids)
sources_children_entries = "\n".join(sources_group_children)

project_pbxproj = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{build_files_str}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{file_refs_str}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{frameworks_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{main_group_id} = {{
			isa = PBXGroup;
			children = (
				{sources_group_id} /* Sources */,
				{resources_ref_id} /* Resources */,
				{products_group_id} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{products_group_id} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_product_id} /* StillFantasyiPad.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{sources_group_id} /* Sources */ = {{
			isa = PBXGroup;
			children = (
{sources_children_entries}
			);
			name = Sources;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{target_id} /* StillFantasyiPad */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {target_cfg_list_id} /* Build configuration list for PBXNativeTarget "StillFantasyiPad" */;
			buildPhases = (
				{sources_phase_id} /* Sources */,
				{frameworks_phase_id} /* Frameworks */,
				{resources_phase_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = StillFantasyiPad;
			productName = StillFantasyiPad;
			productReference = {app_product_id} /* StillFantasyiPad.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{proj_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {{
					{target_id} = {{
						CreatedOnToolsVersion = 15.0;
					}};
				}};
			}};
			buildConfigurationList = {proj_cfg_list_id} /* Build configuration list for PBXProject "StillFantasyiPad" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_id};
			productRefGroup = {products_group_id} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{target_id} /* StillFantasyiPad */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{resources_phase_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{resources_build_id} /* Resources in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{sources_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{sources_phase_entries}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{proj_debug_cfg_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{proj_release_cfg_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_OPTIMIZATION_LEVEL = s;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			}};
			name = Release;
		}};
		{target_debug_cfg_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Still Fantasy";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillfantasy.ipad;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{target_release_cfg_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Still Fantasy";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillfantasy.ipad;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{proj_cfg_list_id} /* Build configuration list for PBXProject "StillFantasyiPad" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{proj_debug_cfg_id} /* Debug */,
				{proj_release_cfg_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{target_cfg_list_id} /* Build configuration list for PBXNativeTarget "StillFantasyiPad" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{target_debug_cfg_id} /* Debug */,
				{target_release_cfg_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

	}};
	rootObject = {proj_id} /* Project object */;
}}
"""

xcodeproj_dir = os.path.join(project_dir, "StillFantasyiPad.xcodeproj")
os.makedirs(xcodeproj_dir, exist_ok=True)
pbxproj_path = os.path.join(xcodeproj_dir, "project.pbxproj")

with open(pbxproj_path, "w", encoding="utf-8") as f:
    f.write(project_pbxproj)

print(f"Successfully generated {pbxproj_path}")

# Generate scheme
scheme_dir = os.path.join(xcodeproj_dir, "xcshareddata/xcschemes")
os.makedirs(scheme_dir, exist_ok=True)
scheme_path = os.path.join(scheme_dir, "StillFantasyiPad.xcscheme")

scheme_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{target_id}"
               BuildableName = "StillFantasyiPad.app"
               BlueprintName = "StillFantasyiPad"
               ReferencedContainer = "container:StillFantasyiPad.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_id}"
            BuildableName = "StillFantasyiPad.app"
            BlueprintName = "StillFantasyiPad"
            ReferencedContainer = "container:StillFantasyiPad.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_id}"
            BuildableName = "StillFantasyiPad.app"
            BlueprintName = "StillFantasyiPad"
            ReferencedContainer = "container:StillFantasyiPad.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""

with open(scheme_path, "w", encoding="utf-8") as f:
    f.write(scheme_content)

print(f"Successfully generated {scheme_path}")
