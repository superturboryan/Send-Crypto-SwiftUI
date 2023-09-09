//
//  CompositionRoot.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-09.
//

import SwiftUI

enum CompositionRoot {
    
    static let rootView: RootView = RootView()
    
    static var fiatSelectorView: ((Double, Binding<FiatType>) -> FiatSelectorView) = { (amount, selection) in
        FiatSelectorView(selectedAmount: amount, selectedFiat: selection)
    }
    
    static let ethPrice = EthPrice(ethPriceService: ethPriceNetworkService)
    
    private static let ethPriceNetworkService = EthPriceNetworkService()
}
