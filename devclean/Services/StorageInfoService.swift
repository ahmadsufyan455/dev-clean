// StorageInfoService.swift
// devclean

import Foundation

struct VolumeStorageInfo {
    let totalBytes: Int64
    let availableBytes: Int64

    var usedBytes: Int64 { totalBytes - availableBytes }
}

final class StorageInfoService {

    /// Queries the boot volume for real total and available capacity.
    /// Uses NSURLVolumeTotalCapacityKey / NSURLVolumeAvailableCapacityForImportantUsageKey
    /// which are available via Foundation — no IOKit required.
    func queryBootVolume() -> VolumeStorageInfo {
        let url = URL(fileURLWithPath: "/")
        let keys: Set<URLResourceKey> = [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ]

        guard let values = try? url.resourceValues(forKeys: keys),
              let total = values.volumeTotalCapacity,
              let available = values.volumeAvailableCapacityForImportantUsage
        else {
            return VolumeStorageInfo(totalBytes: 0, availableBytes: 0)
        }

        return VolumeStorageInfo(
            totalBytes: Int64(total),
            availableBytes: available
        )
    }
}
