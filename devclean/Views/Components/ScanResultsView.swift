// ScanResultsView.swift
// devclean

import SwiftUI

// MARK: - Root results view

struct ScanResultsView: View {
    @Environment(DashboardViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Active processes warning banner
            if !viewModel.runningIDEs.isEmpty {
                ActiveProcessBanner(runningApps: viewModel.runningIDEs)
            }

            // Section title
            Text("Cleaning Categories")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            // One card per tool (always shown after scan)
            VStack(spacing: 12) {
                ForEach(viewModel.categoriesByTool, id: \.tool) { group in
                    ToolCategoryCard(tool: group.tool, categories: group.categories)
                }
            }

            // All Clean panel when nothing reclaimable found
            if viewModel.totalReclaimableBytes == 0 {
                AllCleanPanel()
            }
        }
    }
}

// MARK: - Active process warning banner

private struct ActiveProcessBanner: View {
    let runningApps: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "#F5A623"))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 8) {
                Text("Active Processes Detected")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "#F5A623"))

                Text("The following applications are currently running. Cleaning their caches may cause unexpected behavior. Consider closing them before proceeding.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#D1D5DC"))
                    .fixedSize(horizontal: false, vertical: true)

                // App chips
                HStack(spacing: 8) {
                    ForEach(runningApps, id: \.self) { app in
                        Text(app)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: "#D1D5DC"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "#2F2F2F"))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F5A623").opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F5A623").opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Tool category card

private struct ToolCategoryCard: View {
    @Environment(DashboardViewModel.self) private var viewModel
    let tool: DeveloperTool
    let categories: [CleanableCategory]

    private var toolTotalSize: Int64 { viewModel.totalSize(for: tool) }
    private var isEnabled: Bool { viewModel.isToolEnabled(tool) }

    private var toolDisplayName: String {
        switch tool {
        case .xcode:         return "Xcode"
        case .android:       return "Android Studio"
        case .flutter:       return "Flutter"
        case .projectLevel:  return "Project"
        }
    }

    private var toolIcon: String {
        switch tool {
        case .xcode:         return "hammer.fill"
        case .android:       return "square.stack.3d.up.fill"
        case .flutter:       return "wind"
        case .projectLevel:  return "folder.fill"
        }
    }

    private var toolColor: Color {
        switch tool {
        case .xcode:         return Color(hex: "#2B7FFF")
        case .android:       return Color(hex: "#00C950")
        case .flutter:       return Color(hex: "#54C5F8")
        case .projectLevel:  return Color(hex: "#AD46FF")
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // Tool icon badge
            ZStack {
                toolColor.opacity(0.15)
                Image(systemName: toolIcon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(toolColor)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Name + size badge
                HStack(spacing: 8) {
                    Text(toolDisplayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    // Size badge
                    Text(ByteFormatter.string(fromBytes: toolTotalSize))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(toolTotalSize > 0 ? toolColor : Color(hex: "#99A1AF"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((toolTotalSize > 0 ? toolColor : Color(hex: "#99A1AF")).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                // Target paths list
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(categories, id: \.id) { category in
                        ForEach(category.targetPaths, id: \.self) { path in
                            HStack(spacing: 6) {
                                Image(systemName: "folder")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "#99A1AF"))
                                Text(abbreviatedPath(path))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#99A1AF"))
                            }
                        }
                    }
                }
            }

            Spacer()

            // Toggle
            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { viewModel.setToolEnabled(tool, enabled: $0) }
            ))
            .toggleStyle(.switch)
            .tint(toolColor)
            .labelsHidden()
            .disabled(toolTotalSize == 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }

    /// Converts "~/Library/Developer/Xcode/DerivedData" → "~/DerivedData"
    /// keeping it short for display.
    private func abbreviatedPath(_ path: String) -> String {
        let components = path.components(separatedBy: "/")
        guard components.count > 2 else { return path }
        return "~/" + components.suffix(1).joined(separator: "/")
    }
}

// MARK: - All clean panel

struct AllCleanPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "#00C950").opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(hex: "#00C950"))
            }

            VStack(spacing: 6) {
                Text("All Clean!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Your system is optimized. No reclaimable space found.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }
}
