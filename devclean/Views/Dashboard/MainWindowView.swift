// MainWindowView.swift
// devclean
//
// Root layout: titlebar + sidebar + content area.

import SwiftUI

struct MainWindowView: View {
    @State private var sidebarSelection: SidebarItem = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            // Custom titlebar
            TitleBarView()

            // Body: sidebar + content
            HStack(spacing: 0) {
                SidebarView(selection: $sidebarSelection)

                Group {
                    switch sidebarSelection {
                    case .dashboard:
                        DashboardView()
                    case .history:
                        PlaceholderView(title: "History", icon: "clock")
                    case .settings:
                        PlaceholderView(title: "Settings", icon: "gearshape")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(hex: "#1E1E1E"))
        // Remove default macOS titlebar so our custom one takes over
        .ignoresSafeArea()
    }
}

// MARK: - Titlebar

private struct TitleBarView: View {
    var body: some View {
        ZStack {
            Color(hex: "#2A2A2A")

            Text("DevClean")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "#D1D5DC"))
                .tracking(-0.15)
        }
        .frame(height: 52)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#3A3A3A"))
                .frame(height: 1)
        }
    }
}

// MARK: - Placeholder

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color(hex: "#3A3A3A"))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "#3A3A3A"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#1E1E1E"))
    }
}
