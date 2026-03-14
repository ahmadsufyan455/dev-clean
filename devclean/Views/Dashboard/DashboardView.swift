// DashboardView.swift
// devclean

import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @State private var permanentDelete: Bool = false

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
                        totalBytes: viewModel.volumeInfo.totalBytes,
                        usedBytes: viewModel.volumeInfo.usedBytes
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

                    // Split clean button: primary action + mode picker
                    let cleanDisabled = viewModel.totalReclaimableBytes == 0 || viewModel.isCleaning || viewModel.isScanning
                    HStack(spacing: 0) {
                        // Primary action
                        Button {
                            Task { await viewModel.cleanSelected(permanent: permanentDelete) }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: permanentDelete ? "trash.slash" : "trash")
                                    .font(.system(size: 16))
                                Text(permanentDelete ? "Delete \(viewModel.totalReclaimableDisplay)" : "Move to Trash \(viewModel.totalReclaimableDisplay)")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 48)
                        }
                        .buttonStyle(.plain)
                        .disabled(cleanDisabled)

                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 1, height: 28)

                        // Mode picker chevron
                        Menu {
                            Button {
                                permanentDelete = false
                            } label: {
                                Label("Move to Trash", systemImage: permanentDelete ? "" : "checkmark")
                            }
                            Button(role: .destructive) {
                                permanentDelete = true
                            } label: {
                                Label("Delete Permanently", systemImage: permanentDelete ? "checkmark" : "")
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .menuStyle(.borderlessButton)
                        .menuIndicator(.hidden)
                        .frame(width: 44, height: 48)
                        .contentShape(Rectangle())
                        .disabled(cleanDisabled)
                    }
                    .background(permanentDelete ? Color(hex: "#C0392B") : Color(hex: "#155DFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(cleanDisabled ? 0.5 : 1)
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
        case .scanning(let progress, let category):
            ScanningView(progress: progress, currentCategory: category)
        case .scanned:
            ScanResultsView()
        case .cleaning(let progress):
            CleaningView(progress: progress)
        case .complete(let freed):
            VStack(alignment: .leading, spacing: 16) {
                ScanResultsView()
                CleanCompleteView(totalFreed: freed) {
                    viewModel.resetToIdle()
                }
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
