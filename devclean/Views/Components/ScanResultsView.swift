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

    @State private var isExpanded: Bool = true

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
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .center, spacing: 16) {

                // Tool icon badge
                ZStack {
                    toolColor.opacity(0.15)
                    Image(systemName: toolIcon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(toolColor)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Name + size badge
                VStack(alignment: .leading, spacing: 4) {
                    Text(toolDisplayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(ByteFormatter.string(fromBytes: toolTotalSize))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(toolTotalSize > 0 ? toolColor : Color(hex: "#99A1AF"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((toolTotalSize > 0 ? toolColor : Color(hex: "#99A1AF")).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Spacer()

                // Select-all toggle
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { viewModel.setToolEnabled(tool, enabled: $0) }
                ))
                .toggleStyle(.switch)
                .tint(toolColor)
                .labelsHidden()
                .disabled(toolTotalSize == 0)

                // Expand/collapse chevron
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            // Expanded: per-category sections with item checklists
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .background(Color(hex: "#3A3A3A"))

                    ForEach(categories, id: \.id) { category in
                        CategorySection(category: category, toolColor: toolColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }
}

// MARK: - Category section (within a tool card)

private struct CategorySection: View {
    @Environment(DashboardViewModel.self) private var viewModel
    let category: CleanableCategory
    let toolColor: Color

    private var isCategorySelected: Bool {
        !category.items.isEmpty && category.items.allSatisfy(\.isSelected)
    }

    private var isCategoryIndeterminate: Bool {
        !isCategorySelected && category.items.contains(where: \.isSelected)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category header row
            HStack(spacing: 10) {
                // Category-level checkbox
                CheckboxButton(
                    isChecked: isCategorySelected,
                    isIndeterminate: isCategoryIndeterminate,
                    isDisabled: category.items.isEmpty,
                    color: toolColor
                ) {
                    viewModel.setCategoryEnabled(category, enabled: !isCategorySelected)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(category.items.isEmpty ? Color(hex: "#555555") : .white)

                    Text(category.description)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "#6B7280"))
                        .lineLimit(1)
                }

                Spacer()

                Text(ByteFormatter.string(fromBytes: category.totalSizeInBytes))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(category.totalSizeInBytes > 0 ? Color(hex: "#99A1AF") : Color(hex: "#444444"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Item rows
            if !category.items.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(category.items.enumerated()), id: \.element.id) { index, item in
                        ItemRow(item: item, toolColor: toolColor) { selected in
                            viewModel.setItemSelected(category: category, item: item, selected: selected)
                        }

                        if index < category.items.count - 1 {
                            Divider()
                                .background(Color(hex: "#2F2F2F"))
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color(hex: "#1E1E1E"))
            } else {
                // Empty state for this category
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#444444"))
                    Text("Nothing to clean")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#555555"))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .padding(.leading, 28)
            }

            Divider()
                .background(Color(hex: "#3A3A3A"))
        }
    }
}

// MARK: - Individual item row

private struct ItemRow: View {
    let item: DiskItem
    let toolColor: Color
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Indent
            Color.clear.frame(width: 20)

            CheckboxButton(
                isChecked: item.isSelected,
                isIndeterminate: false,
                isDisabled: false,
                color: toolColor,
                action: { onToggle(!item.isSelected) }
            )

            Image(systemName: item.type == .directory ? "folder.fill" : "doc.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "#6B7280"))

            Text(item.name)
                .font(.system(size: 12))
                .foregroundStyle(item.isSelected ? Color(hex: "#D1D5DC") : Color(hex: "#6B7280"))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Text(ByteFormatter.string(fromBytes: item.sizeInBytes))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(item.isSelected ? Color(hex: "#99A1AF") : Color(hex: "#444444"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onToggle(!item.isSelected) }
    }
}

// MARK: - Checkbox button

private struct CheckboxButton: View {
    let isChecked: Bool
    let isIndeterminate: Bool
    let isDisabled: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(checkFill)
                    .frame(width: 18, height: 18)

                RoundedRectangle(cornerRadius: 5)
                    .stroke(checkBorder, lineWidth: 1.5)
                    .frame(width: 18, height: 18)

                if isIndeterminate {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: 8, height: 2)
                } else if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var checkFill: Color {
        if isDisabled { return Color(hex: "#2A2A2A") }
        if isChecked || isIndeterminate { return color }
        return Color(hex: "#2A2A2A")
    }

    private var checkBorder: Color {
        if isDisabled { return Color(hex: "#3A3A3A") }
        if isChecked || isIndeterminate { return color }
        return Color(hex: "#555555")
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
