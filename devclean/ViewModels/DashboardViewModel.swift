// DashboardViewModel.swift
// devclean

import Foundation
import Observation

// MARK: - State

enum DashboardState: Equatable {
    case idle
    case scanning(progress: Double, currentCategory: String)
    case scanned
    case cleaning(progress: Double)
    case complete(totalFreed: Int64)
    case error(String)

    static func == (lhs: DashboardState, rhs: DashboardState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.scanning(let a, let c), .scanning(let b, let d)): return a == b && c == d
        case (.scanned, .scanned): return true
        case (.cleaning(let a), .cleaning(let b)): return a == b
        case (.complete(let a), .complete(let b)): return a == b
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - Published state

    var state: DashboardState = .idle
    var categories: [CleanableCategory] = []
    var installedTools: Set<DeveloperTool> = []
    var volumeInfo: VolumeStorageInfo = VolumeStorageInfo(totalBytes: 0, availableBytes: 0)
    var runningIDEs: [String] = []

    // MARK: - Dependencies

    private let scanner: DiskScannerServiceProtocol
    private let cleaner: CleaningServiceProtocol
    private let appDetection: AppDetectionService
    private let storageInfoService: StorageInfoService

    // MARK: - Init

    init(
        scanner: DiskScannerServiceProtocol,
        cleaner: CleaningServiceProtocol,
        appDetection: AppDetectionService,
        storageInfo: StorageInfoService
    ) {
        self.scanner = scanner
        self.cleaner = cleaner
        self.appDetection = appDetection
        self.storageInfoService = storageInfo
    }

    // MARK: - Computed

    var totalReclaimableBytes: Int64 {
        categories.reduce(0) { $0 + $1.selectedSizeInBytes }
    }

    var totalReclaimableDisplay: String {
        ByteFormatter.string(fromBytes: totalReclaimableBytes)
    }

    var isScanning: Bool {
        if case .scanning = state { return true }
        return false
    }

    var hasResults: Bool {
        if case .scanned = state { return true }
        return false
    }

    var categoriesWithItems: [CleanableCategory] {
        categories.filter { !$0.items.isEmpty }
    }

    /// Groups all installed categories by DeveloperTool for the scan results view.
    /// Always shows all detected tools, even if their size is 0.
    var categoriesByTool: [(tool: DeveloperTool, categories: [CleanableCategory])] {
        let tools: [DeveloperTool] = [.xcode, .android, .flutter, .projectLevel]
        return tools.compactMap { tool in
            let cats = categories.filter { $0.tool == tool }
            guard !cats.isEmpty else { return nil }
            return (tool: tool, categories: cats)
        }
    }

    /// Total size for a given tool across all its categories.
    func totalSize(for tool: DeveloperTool) -> Int64 {
        categories.filter { $0.tool == tool }.reduce(0) { $0 + $1.totalSizeInBytes }
    }

    /// Whether all items in a tool group are selected.
    func isToolEnabled(_ tool: DeveloperTool) -> Bool {
        let items = categories.filter { $0.tool == tool }.flatMap(\.items)
        return !items.isEmpty && items.allSatisfy(\.isSelected)
    }

    /// Select or deselect all items for a tool.
    func setToolEnabled(_ tool: DeveloperTool, enabled: Bool) {
        for catIndex in categories.indices where categories[catIndex].tool == tool {
            for itemIndex in categories[catIndex].items.indices {
                categories[catIndex].items[itemIndex].isSelected = enabled
            }
        }
    }

    /// Select or deselect all items within a single category.
    func setCategoryEnabled(_ category: CleanableCategory, enabled: Bool) {
        guard let catIndex = categories.firstIndex(where: { $0.id == category.id }) else { return }
        for itemIndex in categories[catIndex].items.indices {
            categories[catIndex].items[itemIndex].isSelected = enabled
        }
    }

    /// Toggle a single item's selection state.
    func setItemSelected(category: CleanableCategory, item: DiskItem, selected: Bool) {
        guard let catIndex = categories.firstIndex(where: { $0.id == category.id }),
              let itemIndex = categories[catIndex].items.firstIndex(where: { $0.id == item.id })
        else { return }
        categories[catIndex].items[itemIndex].isSelected = selected
    }

    var isCleaning: Bool {
        if case .cleaning = state { return true }
        return false
    }

    // MARK: - Actions

    /// Call once on app launch to filter categories to installed tools and load storage info.
    func loadInstalledTools() {
        installedTools = appDetection.detectInstalledTools()
        categories = DevPaths.allCategories.filter {
            installedTools.contains($0.tool) || $0.tool == .projectLevel
        }
        volumeInfo = storageInfoService.queryBootVolume()
    }

    /// Refresh the live storage numbers (call after cleaning completes).
    func refreshVolumeInfo() {
        volumeInfo = storageInfoService.queryBootVolume()
    }

    /// Scan all visible categories for junk files.
    func startScan() async {
        guard !isScanning else { return }

        // Reset previous results
        for index in categories.indices {
            categories[index].items = []
        }
        runningIDEs = appDetection.detectRunningIDEs()
        state = .scanning(progress: 0, currentCategory: "")

        do {
            for (catIndex, category) in categories.enumerated() {
                let urls = category.targetPaths
                    .map { PathHelper.url(for: $0) }
                    .filter { PathHelper.exists($0) }

                guard !urls.isEmpty else { continue }

                state = .scanning(
                    progress: Double(catIndex) / Double(max(categories.count, 1)),
                    currentCategory: category.name
                )

                // Scan only top-level children of each target path so we get
                // meaningful per-project/per-module entries instead of raw files.
                let items = try await scanner.scanTopLevel(urls: urls) { [weak self] progress in
                    guard let self else { return }
                    let overall = (Double(catIndex) + progress) / Double(self.categories.count)
                    self.state = .scanning(progress: overall, currentCategory: category.name)
                }

                if let index = categories.firstIndex(where: { $0.id == category.id }) {
                    categories[index].items = items
                }
            }
            state = .scanned
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Clean all currently selected items across all categories.
    func cleanSelected(permanent: Bool = false) async {
        guard !isCleaning else { return }

        let allSelectedItems = categories.flatMap(\.selectedItems)
        guard !allSelectedItems.isEmpty else { return }

        state = .cleaning(progress: 0)
        var totalFreed: Int64 = 0

        do {
            let results: [CleaningResult]
            if permanent {
                results = try await cleaner.clean(items: allSelectedItems) { [weak self] progress in
                    self?.state = .cleaning(progress: progress)
                }
            } else {
                results = try await cleaner.moveToTrash(items: allSelectedItems) { [weak self] progress in
                    self?.state = .cleaning(progress: progress)
                }
            }

            for result in results {
                if case .success(_, let freed) = result {
                    totalFreed += freed
                }
            }

            // Remove cleaned items from categories
            let cleanedURLs = Set(results.compactMap { result -> URL? in
                if case .success(let item, _) = result { return item.url }
                return nil
            })
            for index in categories.indices {
                categories[index].items.removeAll { cleanedURLs.contains($0.url) }
            }

            refreshVolumeInfo()
            let remaining = categories.flatMap(\.items).count
            state = remaining > 0 ? .scanned : .complete(totalFreed: totalFreed)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func resetToIdle() {
        for index in categories.indices {
            categories[index].items = []
        }
        state = .idle
    }
}
