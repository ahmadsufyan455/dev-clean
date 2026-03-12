// SettingsViewModel.swift
// devclean

import Foundation
import Observation
import AppKit

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - General
    var autoScanOnLaunch: Bool = false
    var notificationsEnabled: Bool = true

    // MARK: - Safety
    var activeProcessDetection: Bool = true
    var confirmBeforeDeletion: Bool = true

    // MARK: - Permissions
    var hasFullDiskAccess: Bool {
        // Probe a protected path; if readable, access is granted
        FileManager.default.isReadableFile(atPath: "/Library/Application Support")
    }

    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(url)
        }
    }
}
