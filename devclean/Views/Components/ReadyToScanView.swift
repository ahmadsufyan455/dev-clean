// ReadyToScanView.swift
// devclean

import SwiftUI

struct ReadyToScanView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Scan icon circle
            ZStack {
                Circle()
                    .fill(Color(hex: "#2F2F2F"))
                    .frame(width: 80, height: 80)
                Image(systemName: "viewfinder")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }

            VStack(spacing: 8) {
                Text("Ready to Scan")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Click \"Scan Now\" to analyze your system and discover how much space you can reclaim from development caches.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#99A1AF"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

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

struct ScanningView: View {
    let progress: Double
    let currentCategory: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView(value: max(progress, 0.02))
                .progressViewStyle(.linear)
                .tint(
                    LinearGradient(
                        colors: [Color(hex: "#2B7FFF"), Color(hex: "#AD46FF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: 320)

            VStack(spacing: 6) {
                Text("Scanning…")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                if !currentCategory.isEmpty {
                    Text("Scanning \(currentCategory)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }
                Text("\(Int(progress * 100))% complete")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#99A1AF").opacity(0.6))
            }

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

struct CleaningView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(Color(hex: "#00C950"))
                .frame(maxWidth: 320)

            VStack(spacing: 6) {
                Text("Cleaning…")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(Int(progress * 100))% complete")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }

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

struct CleanCompleteView: View {
    let totalFreed: Int64
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "#00C950").opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "#00C950"))
            }

            VStack(spacing: 8) {
                Text("All Clean!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Freed \(ByteFormatter.string(fromBytes: totalFreed)) of disk space.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }

            Button("Scan Again", action: onReset)
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
