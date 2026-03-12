// CleaningServiceProtocol.swift
// devclean

import Foundation

/// The result of attempting to delete a single DiskItem.
enum CleaningResult: Sendable {
    case success(item: DiskItem, freedBytes: Int64)
    case failure(item: DiskItem, error: Error)
}

protocol CleaningServiceProtocol: AnyObject, Sendable {

    /// Permanently deletes the given items and reports per-item results.
    /// - Parameters:
    ///   - items: Items to delete. Callers should pre-filter to only selected items.
    ///   - progressHandler: Called with a value in 0.0–1.0 after each item is processed.
    func clean(
        items: [DiskItem],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [CleaningResult]

    /// Moves items to the system Trash — safer default before permanent deletion is confirmed.
    func moveToTrash(
        items: [DiskItem],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [CleaningResult]

    /// Calculates bytes that would be freed without performing any deletion.
    /// Use to populate confirmation dialogs.
    func projectedFreedSpace(for items: [DiskItem]) -> Int64
}
