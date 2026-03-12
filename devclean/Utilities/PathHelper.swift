// PathHelper.swift
// devclean

import Foundation

enum PathHelper {

    /// Expands a path string containing `~` to its full absolute path.
    /// e.g. "~/Library/..." → "/Users/johndoe/Library/..."
    static func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    /// Converts an unexpanded path string to a file URL.
    static func url(for path: String) -> URL {
        URL(fileURLWithPath: expand(path))
    }

    /// Returns true if the expanded path exists on disk (file or directory).
    static func exists(_ path: String) -> Bool {
        FileManager.default.fileExists(atPath: expand(path))
    }

    /// Returns true if the given URL exists on disk.
    static func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    /// Resolves any symlinks in the URL and returns the canonical path URL.
    static func resolved(_ url: URL) -> URL {
        url.resolvingSymlinksInPath()
    }

    /// Returns the parent directory URL of the given URL.
    static func parent(of url: URL) -> URL {
        url.deletingLastPathComponent()
    }
}
