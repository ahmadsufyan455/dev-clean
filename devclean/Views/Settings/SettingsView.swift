// SettingsView.swift
// devclean

import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Page header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.4)

                    Text("Configure DevClean preferences and safety options")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }
                .padding(.bottom, 8)

                // Permissions
                PermissionsSection(viewModel: viewModel)

                // General
                GeneralSection(viewModel: viewModel)

                // Safety
                SafetySection(viewModel: viewModel)

                // Custom Directories
                CustomDirectoriesSection()
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(hex: "#1E1E1E"))
    }
}

// MARK: - Permissions

private struct PermissionsSection: View {
    let viewModel: SettingsViewModel

    var body: some View {
        SettingsCard {
            // Section header
            SectionHeader(icon: "lock.shield", title: "Permissions", iconColor: Color(hex: "#2B7FFF"))

            // Full Disk Access banner
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#2B7FFF"))
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Disk Access Required")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: "#2B7FFF"))

                        Text("DevClean needs Full Disk Access to scan and clean cache directories in ~/Library and hidden folders.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#D1D5DC"))
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            viewModel.openSystemSettings()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Open System Settings")
                                    .font(.system(size: 14, weight: .medium))
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(Color(hex: "#155DFC"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "#2B7FFF").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#2B7FFF").opacity(0.2), lineWidth: 1)
            )

            // Step-by-step instructions
            VStack(alignment: .leading, spacing: 4) {
                Text("To enable Full Disk Access:")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))

                let steps = [
                    "Open System Settings → Privacy & Security → Full Disk Access",
                    "Click the lock icon and authenticate",
                    "Toggle on \"DevClean\"",
                    "Restart the application"
                ]

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "#99A1AF"))
                            Text(step)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "#99A1AF"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.leading, 8)
            }
        }
    }
}

// MARK: - General

private struct GeneralSection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsCard {
            Text("General")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Auto-scan on launch",
                    description: "Automatically scan for reclaimable space when DevClean starts",
                    isOn: $viewModel.autoScanOnLaunch
                )

                Divider().overlay(Color(hex: "#3A3A3A"))

                SettingsToggleRow(
                    title: "Notifications",
                    description: "Show system notifications when cleaning is complete",
                    isOn: $viewModel.notificationsEnabled
                )
            }
        }
    }
}

// MARK: - Safety

private struct SafetySection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsCard {
            SectionHeader(icon: "shield", title: "Safety", iconColor: Color(hex: "#00C950"))

            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Active process detection",
                    description: "Warn when cleaning caches for currently running IDEs",
                    isOn: $viewModel.activeProcessDetection
                )

                Divider().overlay(Color(hex: "#3A3A3A"))

                SettingsToggleRow(
                    title: "Confirm before deletion",
                    description: "Show confirmation dialog before cleaning files",
                    isOn: $viewModel.confirmBeforeDeletion
                )
            }
        }
    }
}

// MARK: - Custom Directories

private struct CustomDirectoriesSection: View {
    var body: some View {
        SettingsCard {
            HStack(spacing: 12) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#AD46FF"))
                Text("Custom Directories")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Add custom directories to scan for build artifacts (coming soon)")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#99A1AF"))

            Button {
                // coming soon — no-op
            } label: {
                Text("Add Directory")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(Color(hex: "#2F2F2F"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(true)
            .opacity(0.5)
        }
    }
}

// MARK: - Reusable components

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }
}

private struct SectionHeader: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 20, height: 20)
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(Color(hex: "#155DFC"))
                .labelsHidden()
        }
        .padding(.vertical, 12)
    }
}
