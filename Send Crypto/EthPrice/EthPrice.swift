//
//  Crypto.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import Foundation

enum EthPriceError: LocalizedError {
    case noEthPrices
    case noGasPrice
}

protocol EthPriceFetching {
    func pricesForFiat(_ types: [FiatType]) async throws -> [FiatType : Double]
    func priceForFastGas() async throws -> Double
}

final class EthPrice: ObservableObject {
    
    @Published var isLoading = false
    
    @Published var fiatPrices: [FiatType : Double] = [:]
    @Published var estimatedNetworkFees: Double = 0
    
    // Dependencies
    private var fiatTypes: [FiatType]
    private var ethPriceService: EthPriceFetching
    
    init(
        fiatTypes: [FiatType] = FiatType.allCases,
        ethPriceService: EthPriceFetching = EthPriceNetworkService()
    ) {
        self.fiatTypes = fiatTypes
        self.ethPriceService = ethPriceService
    }
    
    let fiatFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.zeroSymbol = "0"
        nf.numberStyle = .decimal
        // Grouping separator should be locale specific for fiat
        // Figma shows same separator style for all
        nf.groupingSeparator = " "
        nf.usesGroupingSeparator = true
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    let ethFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.zeroSymbol = "0"
        nf.numberStyle = .decimal
        nf.groupingSeparator = " "
        nf.usesGroupingSeparator = true
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 5
        return nf
    }()
    
    @MainActor
    func load() async throws {
        isLoading = true
        do {
            if fiatTypes.isEmpty {
                throw EthPriceError.noEthPrices
            }
            fiatPrices = try await ethPriceService.pricesForFiat(fiatTypes)
            let gasPrice = try await ethPriceService.priceForFastGas()
            estimatedNetworkFees = convertFastGasPriceToEstimatedNetworkCosts(gasPrice)
        } catch {
            isLoading = false
            throw error
        }
        isLoading = false
    }
    
    func convertFiatToEth(_ fiatAmount: Double, fiatType: FiatType) -> Double {
        fiatAmount / (fiatPrices[fiatType] ?? 1)
    }
    
    func convertEthToFiat(_ ethAmount: Double, fiatType: FiatType) -> Double {
        ethAmount * (fiatPrices[fiatType] ?? 1)
    }
    
    /* private */ func convertFastGasPriceToEstimatedNetworkCosts(_ price: Double) -> Double {
        21_000 * price / 100_000_000
    }
}

struct EthPriceNetworkService: EthPriceFetching {
    
    private let decoder = JSONDecoder()
    
    func pricesForFiat(_ types: [FiatType]) async throws -> [FiatType : Double] {
        guard
            let json = try? await get(.ethPrice(types)),
            let coinGeckoResponse = CoinGeckoSimplePrice.fromJson(json)
        else { throw EthPriceError.noEthPrices }
        return coinGeckoResponse.fiatValues
    }
    
    func priceForFastGas() async throws -> Double {
        guard
            let etherScanResponse = try? await get(.gasPrice()),
            let fastGasPrice = Double(etherScanResponse.result.fastGasPrice)
        else { throw EthPriceError.noGasPrice }
        return fastGasPrice
    }
    
    @discardableResult
    private func get<T: Decodable>(_ request: Request<T>) async throws -> T {
        try await fetchData(from: constructed(request))
    }
    
    private func fetchData<T: Decodable>(from request: URLRequest) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedObject = try decoder.decode(T.self, from: data)
        return decodedObject
    }
    
    // TODO: Add tests for this
    private func constructed<T>(_ cryptoRequest: Request<T>) async throws -> URLRequest {
        var components = URLComponents(url: URL(string: cryptoRequest.baseUrlAndPath)!, resolvingAgainstBaseURL: false)!
        components.queryItems = cryptoRequest.queryParameters.map { URLQueryItem(name: $0, value: $1) }
        var request = URLRequest(url: components.url!)
        request.httpMethod = cryptoRequest.httpMethod
        return request
    }
}
