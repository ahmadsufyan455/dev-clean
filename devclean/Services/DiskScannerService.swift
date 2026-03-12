// DiskScannerService.swift
// devclean

import Foundation

final class DiskScannerService: DiskScannerServiceProtocol {

    private let fileManager = FileManager.default

    // MARK: - DiskScannerServiceProtocol

    func scan(
        url: URL,
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [DiskItem] {
        try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return [] }
            return try self.scanDirectory(url: url, progressHandler: progressHandler)
        }.value
    }

    func scan(
        urls: [URL],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [DiskItem] {
        guard !urls.isEmpty else { return [] }

        var allItems: [DiskItem] = []
        for (index, url) in urls.enumerated() {
            let baseProgress = Double(index) / Double(urls.count)
            let sliceSize = 1.0 / Double(urls.count)

            let items = try await scan(url: url) { progress in
                progressHandler?(baseProgress + progress * sliceSize)
            }
            allItems.append(contentsOf: items)
        }
        progressHandler?(1.0)
        return allItems
    }

    func estimatedSize(at url: URL) async throws -> Int64 {
        try await Task.detached(priority: .utility) { [weak self] in
            guard let self else { return 0 }
            return self.directorySize(url: url)
        }.value
    }

    // MARK: - Private

    private func scanDirectory(
        url: URL,
        progressHandler: (@Sendable (Double) -> Void)?
    ) throws -> [DiskItem] {
        guard fileManager.fileExists(atPath: url.path) else { return [] }

        let keys: [URLResourceKey] = [
            .fileSizeKey,
            .isDirectoryKey,
            .contentModificationDateKey,
            .totalFileSizeKey
        ]

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return []
        }

        // Collect all URLs first to compute progress
        var urls: [URL] = []
        for case let fileURL as URL in enumerator {
            urls.append(fileURL)
        }

        var items: [DiskItem] = []
        for (index, fileURL) in urls.enumerated() {
            progressHandler?(Double(index + 1) / Double(max(urls.count, 1)))

            guard let item = try? makeDiskItem(from: fileURL) else { continue }
            items.append(item)
        }

        return items
    }

    private func makeDiskItem(from url: URL) throws -> DiskItem? {
        let resourceValues = try url.resourceValues(forKeys: [
            .fileSizeKey,
            .isDirectoryKey,
            .contentModificationDateKey,
            .totalFileSizeKey
        ])

        let isDirectory = resourceValues.isDirectory ?? false
        // Use totalFileSize for directories (includes content), fileSize for files
        let size = Int64(resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0)
        let modified = resourceValues.contentModificationDate ?? Date.distantPast

        return DiskItem(
            id: url,
            url: url,
            sizeInBytes: size,
            lastModified: modified,
            type: isDirectory ? .directory : .file
        )
    }

    private func directorySize(url: URL) -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            total += Int64(size)
        }
        return total
    }
}
