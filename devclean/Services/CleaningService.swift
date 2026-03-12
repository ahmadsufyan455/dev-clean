// CleaningService.swift
// devclean

import Foundation

final class CleaningService: CleaningServiceProtocol {

    private let fileManager = FileManager.default

    // MARK: - CleaningServiceProtocol

    func clean(
        items: [DiskItem],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [CleaningResult] {
        await performDeletion(items: items, moveToTrash: false, progressHandler: progressHandler)
    }

    func moveToTrash(
        items: [DiskItem],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [CleaningResult] {
        await performDeletion(items: items, moveToTrash: true, progressHandler: progressHandler)
    }

    func projectedFreedSpace(for items: [DiskItem]) -> Int64 {
        items.reduce(0) { $0 + $1.sizeInBytes }
    }

    // MARK: - Private

    private func performDeletion(
        items: [DiskItem],
        moveToTrash: Bool,
        progressHandler: (@Sendable (Double) -> Void)?
    ) async -> [CleaningResult] {
        var results: [CleaningResult] = []
        let total = items.count

        for (index, item) in items.enumerated() {
            let result: CleaningResult
            do {
                if moveToTrash {
                    try fileManager.trashItem(at: item.url, resultingItemURL: nil)
                } else {
                    try fileManager.removeItem(at: item.url)
                }
                result = .success(item: item, freedBytes: item.sizeInBytes)
            } catch {
                result = .failure(item: item, error: error)
            }
            results.append(result)
            progressHandler?(Double(index + 1) / Double(max(total, 1)))
        }

        return results
    }
}
