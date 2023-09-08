//
//  FiatType.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

enum FiatType: String, CaseIterable {
    case eur = "eur"
    case usd = "usd"
    case gbp = "gbp"
    
    var monetaryUnit: String {
        switch self {
        case .eur: return "Euro"
        case .usd: return "Dollar"
        case .gbp: return "Pound"
        }
    }
    
    var image: Image {
        switch self {
        case .eur: return .europe
        case .usd: return .usa
        case .gbp: return .uk
        }
    }
}
