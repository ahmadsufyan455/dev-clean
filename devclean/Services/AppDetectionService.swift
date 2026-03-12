// AppDetectionService.swift
// devclean

import Foundation
import AppKit

/// Inspects the host machine to determine which developer toolchains are installed
/// and which are currently running.
final class AppDetectionService: Sendable {

    /// Returns the set of developer tools installed on this machine.
    func detectInstalledTools() -> Set<DeveloperTool> {
        var installed: Set<DeveloperTool> = []
        if isXcodeInstalled    { installed.insert(.xcode) }
        if isAndroidInstalled  { installed.insert(.android) }
        if isFlutterInstalled  { installed.insert(.flutter) }
        return installed
    }

    /// Returns the names of running IDE processes that DevClean should warn about.
    /// e.g. ["Xcode.app", "Android Studio.app"]
    func detectRunningIDEs() -> [String] {
        let runningApps = NSWorkspace.shared.runningApplications
        let ideNames = ["Xcode", "Android Studio", "IntelliJ IDEA", "AppCode"]
        return runningApps
            .compactMap { $0.localizedName }
            .filter { name in ideNames.contains(where: { name.contains($0) }) }
            .map { "\($0).app" }
    }

    // MARK: - Private install checks

    private var isXcodeInstalled: Bool {
        FileManager.default.fileExists(atPath: "/Applications/Xcode.app")
    }

    private var isAndroidInstalled: Bool {
        let androidStudio = FileManager.default.fileExists(atPath: "/Applications/Android Studio.app")
        let androidSdk = PathHelper.exists("~/.android")
        return androidStudio || androidSdk
    }

    private var isFlutterInstalled: Bool {
        PathHelper.exists("~/flutter/bin/flutter") || PathHelper.exists("~/.pub-cache")
    }
}
