//
//  FiatType.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

enum FiatType: String, CaseIterable {
    case eur
    case usd
    case gbp
    
    var monetaryUnit: String {
        switch self {
        case .eur: return "Euro"
        case .usd: return "Dollar"
        case .gbp: return "Pound"
        }
    }
    
    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .gbp: return "£"
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
