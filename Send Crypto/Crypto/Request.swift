//
//  Request.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import Foundation

struct Request<T: Decodable> {
    
    var api: API
    
    enum API {
        case ethPrice(_ types: [FiatType])
        case gasPrice
    }
    
    static func ethPrice(_ types: [FiatType]) -> Request<[String : [String : Double]]> {
        Request<[String : [String : Double]]>(api: .ethPrice(types))
    }
    
    static func gasPrice() -> Request<EtherScanGasPrice> {
        Request<EtherScanGasPrice>(api: .gasPrice)
    }
    
    // Ideally should have different Request types for different APIs, and not specify baseURL here
    var baseUrlAndPath: String {
        switch api {
        case .ethPrice: return "https://api.coingecko.com/api/v3/simple/price"
        case .gasPrice: return "https://api.etherscan.io/api"
        }
    }
    
    var queryParameters: [String : String] {
        switch api {
        case .ethPrice(let fiatTypes): return [
            "ids" : "ethereum",
            "vs_currencies" : fiatTypes.map(\.rawValue).joined(separator: ","),
        ]
        case .gasPrice: return [
            "module" : "gastracker",
            "action" : "gasoracle",
        ]
        }
    }
    
    var httpMethod: String {
        switch api {
            case .ethPrice, .gasPrice: return "GET"
        }
    }
}
