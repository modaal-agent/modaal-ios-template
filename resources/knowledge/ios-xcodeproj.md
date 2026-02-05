# How to generate the Xcode project (`*.xcodeproj/project.pbxproj` file)

The AI agent (LLM) should NEVER try to generate or edit the top-level Xcode project file (`*.xcodeproj/project.pbxproj`),
as its structure is convoluted and hard to edit/reason about.

Internally, XcodeGen utility is used to generate the actual Xcode project file from the configuration every time the iOS app is being built.
The configuration for the Xcode project file is created during the initial bootstrap.

If absolutely necessary for accomplishing the task at hand, the Xcodegen configuration file could be edited (eg., to specify entitlemenets, etc).
Defer project generation until later `run_ios` MCP tool call.

## Reference

- XcodeGen: https://github.com/yonaskolb/XcodeGen
- The location of the configuration file: `${TARGET_DIR}/src-ios/App/xcodegen.yml`
- Related MCP tools: `projects_bootstrap`, `run_ios`
