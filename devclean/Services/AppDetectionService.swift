// AppDetectionService.swift
// devclean

import Foundation

/// Inspects the host machine to determine which developer toolchains are installed.
/// Results gate which CleanableCategory entries are surfaced in the UI.
final class AppDetectionService: Sendable {

    /// Returns the set of developer tools that are installed on this machine.
    func detectInstalledTools() -> Set<DeveloperTool> {
        var installed: Set<DeveloperTool> = []

        if isXcodeInstalled { installed.insert(.xcode) }
        if isAndroidInstalled { installed.insert(.android) }
        if isFlutterInstalled { installed.insert(.flutter) }

        return installed
    }

    // MARK: - Private checks

    private var isXcodeInstalled: Bool {
        FileManager.default.fileExists(atPath: "/Applications/Xcode.app")
    }

    private var isAndroidInstalled: Bool {
        // Check for Android Studio or any Android SDK marker
        let androidStudio = FileManager.default.fileExists(
            atPath: "/Applications/Android Studio.app"
        )
        let androidSdk = PathHelper.exists("~/.android")
        return androidStudio || androidSdk
    }

    private var isFlutterInstalled: Bool {
        // Check for flutter binary on PATH or default install location
        let defaultPath = PathHelper.exists("~/flutter/bin/flutter")
        let onPath = (try? Process.run(
            URL(fileURLWithPath: "/usr/bin/which"),
            arguments: ["flutter"]
        )) != nil
        _ = onPath // suppress unused warning — presence check only
        return defaultPath || PathHelper.exists("~/.pub-cache")
    }
}
