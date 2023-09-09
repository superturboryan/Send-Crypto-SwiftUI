//
//  Send_CryptoTests.swift
//  Send CryptoTests
//
//  Created by Ryan Forsyth on 2023-09-09.
//

import Combine
import XCTest
@testable import Send_Crypto

final class EthPriceTests: XCTestCase {

    var sut: EthPrice!
    var stubService = StubEthPriceService()
    
    var subscriptions = Set<AnyCancellable>()
    
    func test_ethPrice_loadingState_whenLoadingSucceeds() async throws {
        // Given
        sut = EthPrice(ethPriceService: stubService)
        let expectedStates = [false, true, false]
        var receivedStates = [Bool]()
        let exp = expectation(description: self.description)
        
        sut.$isLoading.prefix(3).collect().sink { isLoading in
            receivedStates = isLoading
            exp.fulfill()
        }.store(in: &subscriptions)
        
        // When
        try await sut.load()
        
        // Then
        await fulfillment(of: [exp], timeout: 0.5)
        XCTAssertEqual(expectedStates, receivedStates)
    }
    
    func test_ethPrice_loadingState_whenLoadingFails() async {
        // Given
        let expectedStates = [false, true, false]
        var receivedStates = [Bool]()
        let exp = expectation(description: self.description)
        
        let errorToThrow = EthPriceError.noGasPrice
        stubService.errorToThrow = errorToThrow
        sut = EthPrice(ethPriceService: stubService)
        sut.$isLoading.prefix(3).collect().sink { isLoading in
            receivedStates = isLoading
            exp.fulfill()
        }.store(in: &subscriptions)
        
        // When
        do {
            try await sut.load()
        } catch {
            XCTAssertEqual(errorToThrow, error as? EthPriceError)
        }
        
        // Then
        await fulfillment(of: [exp], timeout: 0.5)
        XCTAssertEqual(expectedStates, receivedStates)
    }
    
    func test_ethPrice_loadFiatPricesAndNetworkFeesSuccessfully_whenNoErrorsThrown() async throws {
        // Given
        stubService.errorToThrow = nil
        let gasPrice = 20.0
        let fiatPrices: [FiatType : Double] = [
            FiatType.eur : 10,
            FiatType.gbp : 20,
            FiatType.usd : 30
        ]
        stubService.priceForFastGas = gasPrice
        stubService.pricesForFiat = fiatPrices
        sut = EthPrice(ethPriceService: stubService)
        
        // When
        try await sut.load()
        
        // Then
        XCTAssertEqual(sut.fiatPrices, fiatPrices)
        XCTAssertEqual(sut.estimatedNetworkFees, sut.convertFastGasPriceToEstimatedNetworkCosts(gasPrice))
    }
    
    func test_ethPrices_throwsNoEthPrices_whenFiatTypesNotSet() async throws {
        // Given
        sut = EthPrice(fiatTypes: [], ethPriceService: stubService)
        let expectedError = EthPriceError.noEthPrices
        var receivedError: EthPriceError?
        
        // When
        do {
            try await sut.load()
        } catch {
            receivedError = error as? EthPriceError
        }
        
        // Then
        XCTAssertEqual(expectedError, receivedError)
    }
    
    func test_ethPrices_convertEthToFiat() async {
        // Given
        let ethAmount = 10.0
        let fiatPrices: [FiatType : Double] = [
            FiatType.eur : 10,
            FiatType.gbp : 20,
            FiatType.usd : 30
        ]
        stubService.pricesForFiat = fiatPrices
        sut = EthPrice(ethPriceService: stubService)
        
        // When
        try? await sut.load()
        let convertedToEur = sut.convertEthToFiat(ethAmount, fiatType: .eur)
        let convertedToUsd = sut.convertEthToFiat(ethAmount, fiatType: .usd)
        let convertedToGbp = sut.convertEthToFiat(ethAmount, fiatType: .gbp)
        
        // Then
        // Formula: ETH * fiat price
        XCTAssertEqual(convertedToEur, ethAmount * fiatPrices[.eur]!)
        XCTAssertEqual(convertedToUsd, ethAmount * fiatPrices[.usd]!)
        XCTAssertEqual(convertedToGbp, ethAmount * fiatPrices[.gbp]!)
    }
    
    func test_ethPrices_convertFiat() async {
        // Given
        let fiatAmount = 10.0
        let fiatPrices: [FiatType : Double] = [
            FiatType.eur : 10,
            FiatType.gbp : 20,
            FiatType.usd : 30
        ]
        stubService.pricesForFiat = fiatPrices
        sut = EthPrice(ethPriceService: stubService)
        
        // When
        try? await sut.load()
        let convertedToEur = sut.convertFiatToEth(fiatAmount, fiatType: .eur)
        let convertedToUsd = sut.convertFiatToEth(fiatAmount, fiatType: .usd)
        let convertedToGbp = sut.convertFiatToEth(fiatAmount, fiatType: .gbp)
        
        // Then
        // Formula: Fiat / price for fiat
        XCTAssertEqual(convertedToEur, fiatAmount / fiatPrices[.eur]!)
        XCTAssertEqual(convertedToUsd, fiatAmount / fiatPrices[.usd]!)
        XCTAssertEqual(convertedToGbp, fiatAmount / fiatPrices[.gbp]!)
    }
}

struct StubEthPriceService: EthPriceFetching {
    var pricesForFiat = [FiatType : Double]()
    var priceForFastGas: Double = 0
    var errorToThrow: EthPriceError?
    
    func pricesForFiat(_ types: [Send_Crypto.FiatType]) async throws -> [Send_Crypto.FiatType : Double] {
        if let errorToThrow { throw errorToThrow }
        return pricesForFiat
    }
    
    func priceForFastGas() async throws -> Double {
        if let errorToThrow { throw errorToThrow }
        return priceForFastGas
    }
}
