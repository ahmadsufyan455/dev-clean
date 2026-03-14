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

    /// Lazily loaded immediate children (only directories get expanded).
    var children: [DiskItem] = []
    /// Whether the user has expanded this item to show children.
    var isExpanded: Bool = false

    var name: String { url.lastPathComponent }

    static func == (lhs: DiskItem, rhs: DiskItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
