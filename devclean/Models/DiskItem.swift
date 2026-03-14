// DiskItem.swift
// devclean

import Foundation

/// Represents a single file or directory on disk that can be cleaned.
struct DiskItem: Identifiable, Hashable, Sendable {

    enum ItemType: Sendable {
        case file
        case directory
    }

    let id: URL
    let url: URL
    let sizeInBytes: Int64
    let lastModified: Date
    let type: ItemType
    var isSelected: Bool = true
    /// Human-readable override (e.g. simulator name from device.plist). Falls back to the last path component.
    var displayName: String?

    var name: String { displayName ?? url.lastPathComponent }
}
