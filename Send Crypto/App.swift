//
//  Send_CryptoApp.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

@main
struct Send_CryptoApp: App {
    
    @StateObject var ethPrice = EthPrice(
        fiatTypes: [.eur, .usd, .gbp],
        ethPriceService: EthPriceNetworkService()
    )
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(ethPrice)
        }
    }
}
