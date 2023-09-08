//
//  Model.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import Foundation

struct CoinGeckoSimplePrice {
    // private init() {}
    
    let cryptoType: String
    let fiatValues: [FiatType: Double]
    
    static func fromJson(_ json: [String : Any]) -> CoinGeckoSimplePrice? {
        guard
            let cryptoType = json.keys.first,
            let fiatJson = (json[cryptoType] as? [String : Double])
        else { return nil }
        
        var fiatValues = [FiatType : Double]()
        for (fiatString, value) in fiatJson {
            if let type = FiatType(rawValue: fiatString) {
                fiatValues[type] = value
            }
        }
        
        return CoinGeckoSimplePrice(
            cryptoType: cryptoType,
            fiatValues: fiatValues
        )
    }
}

struct EtherScanGasPrice: Decodable {
    let result: Result

    struct Result: Decodable {
        let fastGasPrice: String
        
        enum CodingKeys: String, CodingKey {
            case fastGasPrice = "FastGasPrice"
        }
    }
}
