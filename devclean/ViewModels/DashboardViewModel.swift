// DashboardViewModel.swift
// devclean

import Foundation
import Observation

// MARK: - State

enum DashboardState: Equatable {
    case idle
    case scanning(progress: Double)
    case cleaning(progress: Double)
    case complete(totalFreed: Int64)
    case error(String)

    static func == (lhs: DashboardState, rhs: DashboardState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.scanning(let a), .scanning(let b)): return a == b
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

    // MARK: - Dependencies

    private let scanner: DiskScannerServiceProtocol
    private let cleaner: CleaningServiceProtocol
    private let appDetection: AppDetectionService

    // MARK: - Init

    init(
        scanner: DiskScannerServiceProtocol,
        cleaner: CleaningServiceProtocol,
        appDetection: AppDetectionService
    ) {
        self.scanner = scanner
        self.cleaner = cleaner
        self.appDetection = appDetection
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

    var isCleaning: Bool {
        if case .cleaning = state { return true }
        return false
    }

    // MARK: - Actions

    /// Call once on app launch to filter categories to installed tools.
    func loadInstalledTools() {
        installedTools = appDetection.detectInstalledTools()
        categories = DevPaths.allCategories.filter {
            installedTools.contains($0.tool) || $0.tool == .projectLevel
        }
    }

    /// Scan all visible categories for junk files.
    func startScan() async {
        guard !isScanning else { return }
        state = .scanning(progress: 0)

        do {
            for (catIndex, category) in categories.enumerated() {
                let urls = category.targetPaths
                    .map { PathHelper.url(for: $0) }
                    .filter { PathHelper.exists($0) }

                guard !urls.isEmpty else { continue }

                let items = try await scanner.scan(urls: urls) { [weak self] progress in
                    guard let self else { return }
                    let overall = (Double(catIndex) + progress) / Double(self.categories.count)
                    self.state = .scanning(progress: overall)
                }

                if let index = categories.firstIndex(where: { $0.id == category.id }) {
                    categories[index].items = items
                }
            }
            state = .idle
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

            state = .complete(totalFreed: totalFreed)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func resetToIdle() {
        state = .idle
    }
}
