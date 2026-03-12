// DashboardView.swift
// devclean

import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel

    // Hardcoded storage info — replace with real IOKit query later
    private let totalStorageBytes: Int64 = 512 * 1_073_741_824   // 512 GB
    private let usedStorageBytes: Int64  = 387 * 1_073_741_824   // 387 GB

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Page header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage Dashboard")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.4)

                    Text("Reclaim disk space by cleaning development caches and build artifacts")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }

                // Storage overview cards
                HStack(spacing: 24) {
                    SystemStorageCard(
                        totalBytes: totalStorageBytes,
                        usedBytes: usedStorageBytes
                    )
                    .frame(height: 190)

                    ReclaimableSpaceCard(
                        reclaimableBytes: viewModel.totalReclaimableBytes
                    )
                    .frame(height: 190)
                }

                // Action buttons
                HStack(spacing: 16) {
                    // Scan Now
                    Button {
                        Task { await viewModel.startScan() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 16))
                            Text("Scan Now")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(Color(hex: "#2F2F2F"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isScanning || viewModel.isCleaning)

                    // Clean button
                    Button {
                        Task { await viewModel.cleanSelected() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                            Text("Clean \(viewModel.totalReclaimableDisplay)")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(Color(hex: "#155DFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .opacity(viewModel.totalReclaimableBytes > 0 && !viewModel.isCleaning ? 1 : 0.5)
                    .disabled(viewModel.totalReclaimableBytes == 0 || viewModel.isCleaning || viewModel.isScanning)
                }

                // State panel
                statePanel
            }
            .padding(32)
        }
        .background(Color(hex: "#1E1E1E"))
        .task {
            viewModel.loadInstalledTools()
        }
    }

    @ViewBuilder
    private var statePanel: some View {
        switch viewModel.state {
        case .idle:
            ReadyToScanView()
        case .scanning(let progress):
            ScanningView(progress: progress)
        case .cleaning(let progress):
            CleaningView(progress: progress)
        case .complete(let freed):
            CleanCompleteView(totalFreed: freed) {
                viewModel.resetToIdle()
            }
        case .error(let message):
            ErrorPanelView(message: message) {
                viewModel.resetToIdle()
            }
        }
    }
}

private struct ErrorPanelView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }
            Button("Dismiss", action: onDismiss)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(hex: "#2F2F2F"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 278)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }
}
