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

    /// Total size in bytes across all items.
    var totalSizeInBytes: Int64 {
        items.reduce(0) { $0 + $1.sizeInBytes }
    }

    /// Total size in bytes of currently selected items.
    var selectedSizeInBytes: Int64 {
        items.filter(\.isSelected).reduce(0) { $0 + $1.sizeInBytes }
    }

    var selectedItems: [DiskItem] {
        items.filter(\.isSelected)
    }
}
