//
//  devcleanApp.swift
//  devclean
//
//  Created by Ahmad Sufyan on 12/03/26.
//

import SwiftUI

@main
struct devcleanApp: App {

    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environment(container.dashboardViewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1143, height: 810)
    }
}
