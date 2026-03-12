// CategoryViewModel.swift
// devclean

import Foundation
import Observation

@Observable
@MainActor
final class CategoryViewModel {

    var category: CleanableCategory

    init(category: CleanableCategory) {
        self.category = category
    }

    // MARK: - Selection

    func selectAll() {
        for index in category.items.indices {
            category.items[index].isSelected = true
        }
    }

    func deselectAll() {
        for index in category.items.indices {
            category.items[index].isSelected = false
        }
    }

    func toggleItem(id: URL) {
        guard let index = category.items.firstIndex(where: { $0.id == id }) else { return }
        category.items[index].isSelected.toggle()
    }

    // MARK: - Sorted views

    var itemsSortedBySize: [DiskItem] {
        category.items.sorted { $0.sizeInBytes > $1.sizeInBytes }
    }

    var itemsSortedByDate: [DiskItem] {
        category.items.sorted { $0.lastModified > $1.lastModified }
    }

    // MARK: - Display helpers

    var totalSizeDisplay: String {
        ByteFormatter.string(fromBytes: category.totalSizeInBytes)
    }

    var selectedSizeDisplay: String {
        ByteFormatter.string(fromBytes: category.selectedSizeInBytes)
    }
}
