//
//  Plausible_Lite_SwiftApp.swift
//  Plausible Lite Swift
//
//  Created by Nicolas Pellerin on 2023-01-02.
//

import SwiftUI

@main
struct Plausible_Lite_SwiftApp: App {
    @StateObject public var store = AppStore()
    @State var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(isLoggedIn: $isLoggedIn, pData: $store.plausibleData)
                .onAppear {
                    AppStore.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let plausibleData):
                            store.plausibleData = plausibleData
                            if store.plausibleData.apiKey.isEmpty && store.plausibleData.siteId.isEmpty {
                                isLoggedIn = false
                            } else {
                                isLoggedIn = true
                            }
                        }
                        
                    }
                }
                .fixedSize()
        }
        .windowResizability(.contentSize)
    }
}
