// CleanableCategory.swift
// devclean

import Foundation

/// The developer tool a category belongs to.
enum DeveloperTool: String, CaseIterable, Sendable {
    case xcode       = "Xcode"
    case android     = "Android"
    case flutter     = "Flutter"
    case projectLevel = "Project"
}

/// A logical grouping of cleanable storage for one tool/category.
struct CleanableCategory: Identifiable, Sendable {

    let id: String
    let name: String
    let description: String
    let tool: DeveloperTool
    /// The root paths this category scans. Resolved at runtime via PathHelper.
    let targetPaths: [String]
    var items: [DiskItem]
    /// Whether this category's toggle is on. When off, nothing is cleaned even if items are checked.
    var isEnabled: Bool = true

    /// Total size in bytes across all items.
    var totalSizeInBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeInBytes }
    }

    /// Size that will actually be freed: checked items only when category is enabled.
    var selectedSizeInBytes: Int64 {
        guard isEnabled else { return 0 }
        return items.filter(\.isSelected).reduce(0) { $0 + $1.sizeInBytes }
    }

    /// Items that will actually be cleaned: checked items only when category is enabled.
    var selectedItems: [DiskItem] {
        guard isEnabled else { return [] }
        return items.filter(\.isSelected)
    }
}
