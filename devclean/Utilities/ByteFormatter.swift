// ByteFormatter.swift
// devclean

import Foundation

enum ByteFormatter {

    private static let formatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        f.countStyle = .file
        f.allowsNonnumericFormatting = false
        return f
    }()

    /// Converts a raw byte count to a human-readable string, e.g. "1.2 GB".
    static func string(fromBytes bytes: Int64) -> String {
        formatter.string(fromByteCount: bytes)
    }

    /// Converts a raw byte count to a human-readable string, e.g. "1.2 GB".
    static func string(fromBytes bytes: Int) -> String {
        string(fromBytes: Int64(bytes))
    }
}
