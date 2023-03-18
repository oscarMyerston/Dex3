//
//  Dex3App.swift
//  Dex3
//
//  Created by Oscar David Myerston Vega on 18/03/23.
//

import SwiftUI

@main
struct Dex3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
