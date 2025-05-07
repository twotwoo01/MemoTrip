//
//  MemoTripApp.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import SwiftUI

@main
struct MemoTripApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
