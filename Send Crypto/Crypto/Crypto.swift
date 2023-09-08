//
//  Crypto.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import Foundation

enum CryptoError: LocalizedError {
    case noEthPrices
    case noGasPrice
}

final class Crypto: ObservableObject {
    
    var fiatTypes: [FiatType]
    
    @Published var isLoading = false
    
    @Published var ethPrices: [FiatType : Double] = [:]
    @Published var gasPrice: Double = 0
    
    private let decoder = JSONDecoder()
    
    init(fiatTypes: [FiatType] = [.eur, .usd, .gbp]) {
        self.fiatTypes = fiatTypes
    }
    
    @MainActor
    func load() async throws {
        isLoading = true
        do {
            ethPrices = try await ethPrices(for: fiatTypes)
            gasPrice = try await gasPrice()
        } catch {
            isLoading = false
            throw error
        }
        isLoading = false
    }
}

// MARK: - APIs
extension Crypto {
    
    func ethPrices(for fiatTypes: [FiatType]) async throws -> [FiatType : Double] {
        guard
            let json = try? await get(.ethPrice(fiatTypes)),
            let coinGeckoResponse = CoinGeckoSimplePrice.fromJson(json)
        else { throw CryptoError.noEthPrices }
        return coinGeckoResponse.fiatValues
    }
    
    func gasPrice() async throws -> Double {
        guard
            let etherScanResponse = try? await get(.gasPrice()),
            let fastGasPrice = Double(etherScanResponse.result.fastGasPrice)
        else { throw CryptoError.noGasPrice }
        return fastGasPrice
    }
}

// MARK: - API request
private extension Crypto {
    
    @discardableResult
    func get<T: Decodable>(_ request: Request<T>) async throws -> T {
        try await fetchData(from: constructed(request))
    }
    
    func fetchData<T: Decodable>(from request: URLRequest) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedObject = try decoder.decode(T.self, from: data)
        return decodedObject
    }
    
    func constructed<T>(_ cryptoRequest: Request<T>) async throws -> URLRequest {
        var components = URLComponents(url: URL(string: cryptoRequest.baseUrlAndPath)!, resolvingAgainstBaseURL: false)!
        components.queryItems = cryptoRequest.queryParameters.map { URLQueryItem(name: $0, value: $1) }
        var request = URLRequest(url: components.url!)
        request.httpMethod = cryptoRequest.httpMethod
        return request
    }
}
