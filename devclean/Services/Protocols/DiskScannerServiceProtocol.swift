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

    /// Returns a fast size estimate in bytes without building a full DiskItem graph.
    /// Used to show approximate totals while a full scan runs in the background.
    func estimatedSize(at url: URL) async throws -> Int64
}
