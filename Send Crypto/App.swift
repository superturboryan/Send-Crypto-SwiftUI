//
//  Send_CryptoApp.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

@main
struct Send_CryptoApp: App {
    
    @StateObject var ethPrice = CompositionRoot.ethPrice
    
    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView
                .environmentObject(ethPrice)
        }
    }
}
