// StorageOverviewCard.swift
// devclean

import SwiftUI

struct SystemStorageCard: View {
    let totalBytes: Int64
    let usedBytes: Int64

    private var freeBytes: Int64 { totalBytes - usedBytes }
    private var usageRatio: Double { totalBytes > 0 ? Double(usedBytes) / Double(totalBytes) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Color(hex: "#2B7FFF").opacity(0.1)
                    Image(systemName: "internaldrive")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#2B7FFF"))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("System Storage")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(totalBytes > 0 ? "\(ByteFormatter.string(fromBytes: totalBytes)) SSD" : "Loading…")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }
            }
            .padding(.bottom, 16)

            // Usage bar
            VStack(spacing: 8) {
                HStack {
                    Text("Used")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                    Spacer()
                    Text("\(ByteFormatter.string(fromBytes: usedBytes)) of \(ByteFormatter.string(fromBytes: totalBytes))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "#1E1E1E"))
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#2B7FFF"), Color(hex: "#AD46FF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * usageRatio, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.bottom, 12)

            // Free space
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(ByteFormatter.string(fromBytes: freeBytes))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("free")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#3A3A3A"), lineWidth: 1)
        )
    }
}

struct ReclaimableSpaceCard: View {
    let reclaimableBytes: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Color(hex: "#00C950").opacity(0.2)
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#00C950"))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Reclaimable Space")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Development caches")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }
            }
            .padding(.bottom, 16)

            // Big number
            Text(ByteFormatter.string(fromBytes: reclaimableBytes))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(hex: "#00C950"))
                .padding(.bottom, 4)

            Text("\(ByteFormatter.string(fromBytes: reclaimableBytes)) total found")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#99A1AF"))

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#00C950").opacity(0.1),
                    Color(hex: "#00BC7D").opacity(0.1)
                ],
                startPoint: UnitPoint(x: 0.1, y: 0),
                endPoint: UnitPoint(x: 0.9, y: 1)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#00C950").opacity(0.2), lineWidth: 1)
        )
    }
}
