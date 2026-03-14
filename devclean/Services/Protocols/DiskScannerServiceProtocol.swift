// DiskScannerServiceProtocol.swift
// devclean

import Foundation

protocol DiskScannerServiceProtocol: AnyObject, Sendable {

    /// Recursively scans a directory URL and returns all children as DiskItem values.
    /// - Parameters:
    ///   - url: The root directory to scan.
    ///   - progressHandler: Called with a value in 0.0–1.0 as scanning progresses.
    func scan(
        url: URL,
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [DiskItem]

    /// Scans multiple URLs in sequence and merges results.
    /// Progress is normalised across all URLs.
    func scan(
        urls: [URL],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [DiskItem]

    /// Scans only the immediate (top-level) children of each URL, computing the
    /// total recursive size for each child. Produces one DiskItem per child entry,
    /// making results meaningful at the project/module level rather than per-file.
    func scanTopLevel(
        urls: [URL],
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> [DiskItem]

    /// Scans the immediate children of a single item URL (used for lazy expand).
    func scanChildren(of url: URL) async throws -> [DiskItem]

    /// Returns a fast size estimate in bytes without building a full DiskItem graph.
    /// Used to show approximate totals while a full scan runs in the background.
    func estimatedSize(at url: URL) async throws -> Int64
}
