// SidebarView.swift
// devclean

import SwiftUI

enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case history   = "History"
    case settings  = "Settings"

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .history:   return "clock"
        case .settings:  return "gearshape"
        }
    }
}

struct SidebarView: View {
    @Binding var selection: SidebarItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App identity
            HStack(spacing: 12) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "#2B7FFF"), Color(hex: "#9810FA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("DevClean")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("v1.0.0")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(hex: "#99A1AF"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)

            // Navigation
            VStack(spacing: 4) {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    SidebarNavButton(item: item, isSelected: selection == item) {
                        selection = item
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            // Footer
            Divider()
                .overlay(Color(hex: "#3A3A3A"))
                .padding(.bottom, 0)

            HStack(spacing: 8) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#99A1AF"))
                Text("Made for developers")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: "#99A1AF"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(width: 220)
        .background(Color(hex: "#252525"))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color(hex: "#3A3A3A"))
                .frame(width: 1)
        }
    }
}

struct SidebarNavButton: View {
    let item: SidebarItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? .white : Color(hex: "#D1D5DC"))
                    .frame(width: 20, height: 20)
                Text(item.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color(hex: "#D1D5DC"))
                Spacer()
            }
            .padding(.leading, 12)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isSelected ? Color(hex: "#155DFC") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
