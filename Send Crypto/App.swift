//
//  Send_CryptoApp.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

@main
struct Send_CryptoApp: App {
    
    @StateObject var crypto = Crypto(fiatTypes: [.eur, .usd, .gbp])
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(crypto)
        }
    }
}
