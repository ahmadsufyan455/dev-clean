// AppContainer.swift
// devclean
//
// Owns and vends all service instances. Created once at app launch.
// Swap concrete types for mocks here during testing.

import Foundation

@MainActor
final class AppContainer {

    // MARK: - Services (singletons within the app lifetime)

    let diskScanner: DiskScannerServiceProtocol = DiskScannerService()
    let cleaningService: CleaningServiceProtocol = CleaningService()
    let appDetection: AppDetectionService = AppDetectionService()

    // MARK: - ViewModels

    lazy var dashboardViewModel: DashboardViewModel = DashboardViewModel(
        scanner: diskScanner,
        cleaner: cleaningService,
        appDetection: appDetection
    )
}
