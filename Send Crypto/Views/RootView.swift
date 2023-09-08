//
//  RootView.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import Combine
import SwiftUI

enum CurrencyType {
    case fiat
    case eth
}

struct RootView: View {
    
    @EnvironmentObject var ethPrice: EthPrice
    
    @State var isViewLoaded = false
    
    @State var userWalletEth: Double = 10
    @State var selectedAmount: Double = 20.23
    @State var selectedCurrencyType: CurrencyType = .fiat
    @State var selectedFiatType: FiatType = .usd
    
    @State var isPresentingFiatSelector = false
    @State var switchSelectedCurrencyButtonRotation: CGFloat = 0
    @FocusState var amountIsFocused: Bool
    @Namespace private var animation
    
    var formattedUserWalletEthAsSelectedFiat: String {
        ethPrice.fiatFormatter.string(
            from: NSNumber(
                value: ethPrice.convertEthToFiat(
                    userWalletEth,
                    fiatType: selectedFiatType
                )
            )
        )!
    }
    
    var formattedUserWalletEth: String {
        ethPrice.ethFormatter.string(
            from: NSNumber(
                value: userWalletEth
            )
        )!
    }
    
    var selectedAmountAsEth: Double {
        ethPrice.convertFiatToEth(selectedAmount, fiatType: selectedFiatType)
    }
    
    var selectedAmountAsFiat: Double {
        ethPrice.convertEthToFiat(selectedAmount, fiatType: selectedFiatType)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            Text("Send Ethereum")
                .font(.system(size: 32, weight: .medium))
                .fullWidth(.leading)
            
            VStack(alignment: .leading, spacing: 16) {
                
                fiatCryptoConversionView
                    .overlay(
                        switchSelectedCurrencyButton,
                        alignment: .leading
                    )
                
                networkFeesView
            }
            
            Spacer()
            
            sendButton
        }
        .padding([.top, .horizontal], 32)
        .padding(.bottom, 16)
        .background(Color.customBG)
        .fullWidthAndHeight()
        .onTapGesture {
            // Tap anywhere on bg to dismiss keyboard/focus for TextField
            amountIsFocused = false
        }
        .sheet(isPresented: $isPresentingFiatSelector) {
            let figmaSheetHeight: CGFloat = 488
            FiatSelectorView(selectedAmount: selectedAmount, selectedFiat: $selectedFiatType)
                .presentationDetents([.height(figmaSheetHeight - 20)])
                .presentationDragIndicator(.visible)
        }
        .task {
            do {
                try await ethPrice.load()
                isViewLoaded = true
            } catch {
                print("Error while loading RootView: \(error)")
                // TODO: Set error state, allow reloading?
            }
        }
    }
    
    @ViewBuilder
    var fiatCryptoConversionView: some View {
        VStack(spacing: 8) {
            
            fiatCryptoConversionViewHeader
            
            // Amount and fiat selection fields
            HStack(alignment: .top) {
                
                // Fiat-Crypto conversion text field + label below
                conversionTextFields
                
                Spacer(minLength: 18)
                
                fiatSelectionButton
            }
        }
        .padding(.leading, 40)
        .padding(.trailing, 18)
        .padding(.vertical, 8)
        .frame(height: 84)
        .roundedCornerBorder(cornerRadius: 8, color: .secondary.opacity(0.4), width: 2)
        .background(.background)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 4)
    }
    
    var fiatCryptoConversionViewHeader: some View {
        HStack {
            Spacer()
            // Max user can send according to their balance
            HStack(spacing: 0) {
                Text("Max ")
                if selectedCurrencyType == .eth {
                    Text(selectedFiatType.symbol)
                }
                Text(selectedCurrencyType == .fiat ? formattedUserWalletEth : formattedUserWalletEthAsSelectedFiat)
                if selectedCurrencyType == .fiat {
                    Text(" ETH")
                }
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.customBlue)
            .frame(height: 16) // Line height 16 in Figma
            .animation(.default, value: selectedCurrencyType)
            .onTapGesture {
                tappedMaxEthAmount()
            }
            
        }
    }
    
    @ViewBuilder
    var conversionTextFields: some View {
        VStack(alignment: .leading, spacing: 3) {
            
            if selectedCurrencyType == .fiat {
                
                // Top amount
                HStack(spacing: 1) {
                    Text("\(selectedFiatType.symbol)")
                    TextField(" Enter Amount", value: $selectedAmount, formatter: ethPrice.fiatFormatter)
                        .keyboardType(.decimalPad)
                        .frame(height: 24)
                        .focused($amountIsFocused)
                }
                .font(.system(size: 20, weight: .medium))
                .matchedGeometryEffect(id: "fiat", in: animation)
                
                // Selected fiat amount converted to ETH
                let formattedEth = ethPrice.ethFormatter.string(from: NSNumber(value: selectedAmountAsEth))!
                let ethAmount = "\(formattedEth) ETH"
                Text(isViewLoaded ? ethAmount : "Loading...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(height: 16)
                    .matchedGeometryEffect(id: "eth", in: animation)
                
            } else if selectedCurrencyType == .eth {
                
                // Top amount
                HStack(spacing: 1) {
                    Text("Ξ")
                    TextField(" Enter Amount", value: $selectedAmount, formatter: ethPrice.ethFormatter)
                        .keyboardType(.decimalPad)
                        .frame(height: 24)
                        .focused($amountIsFocused)
                }
                .font(.system(size: 20, weight: .medium))
                .matchedGeometryEffect(id: "eth", in: animation)
                
                // Selected ETH amount converted to selected fiat typw
                let formattedFiat = ethPrice.fiatFormatter.string(from: NSNumber(value: selectedAmountAsFiat))!
                let fiatAmount = "\(selectedFiatType.symbol)\(formattedFiat)"
                Text(isViewLoaded ? fiatAmount : "Loading...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(height: 16)
                    .matchedGeometryEffect(id: "fiat", in: animation)
                
            }
        }
        .animation(.default, value: selectedCurrencyType)
    }
    
    var fiatSelectionButton: some View {
        Button { isPresentingFiatSelector = true } label: {
            HStack(spacing: 8) {
                selectedFiatType.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .background(.white) // Assets have clear bg
                    .clipShape(Circle()) // Assets are square
                
                Text(selectedFiatType.rawValue.uppercased())
                
                Image(systemName: "chevron.down")
            }
            .fontWeight(.medium) // Applies to text and chevron
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var switchSelectedCurrencyButton: some View {
        let size: CGFloat = 50
        ZStack {
            Color.white
            Image.exchange
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .frame(width: size, height: size)
        .overlay(Circle().strokeBorder(.secondary.opacity(0.2), lineWidth: 2))
        .clipShape(Circle())
        .rotationEffect(.degrees(switchSelectedCurrencyButtonRotation))
        .animation(.default, value: switchSelectedCurrencyButtonRotation)
        .offset(x: -(size / 2))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 4)
        .onTapGesture {
            tappedSwitchSelectedCurrency()
        }
    }
    
    var networkFeesView: some View {
        HStack(spacing: 4) {
            Image(systemName: "info.circle")
            Text("Est. Network fees: " + (isViewLoaded ? "~\(String(format: "%.4F", ethPrice.estimatedNetworkFees)) ETH" : "Loading..."))
                .font(.system(size: 12, weight: .medium))
        }
    }
    
    @ViewBuilder
    var sendButton: some View {
        let convertedToEth = selectedCurrencyType == .fiat ?
        ethPrice.convertFiatToEth(selectedAmount, fiatType: selectedFiatType) :
        selectedAmount
        let formattedEth = ethPrice.ethFormatter.string(from: NSNumber(value: convertedToEth))!
        
        let convertedToFiat = selectedCurrencyType == .eth ?
        ethPrice.convertEthToFiat(selectedAmount, fiatType: selectedFiatType) :
        selectedAmount
        let formattedFiat = ethPrice.fiatFormatter.string(from: NSNumber(floatLiteral: convertedToFiat))!
        
        let doesUserWalletHaveInsufficientFunds = userWalletEth < convertedToEth
        Button {
            print("Sending money to Ryan")
        } label: {
            Text(
                doesUserWalletHaveInsufficientFunds ?
                "Insufficient funds" : (selectedCurrencyType == .eth ?
                    "Send \(formattedEth) ETH" :
                    "Send \(selectedFiatType.symbol)\(formattedFiat) of ETH"))
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 16)
            .fullWidth()
            .foregroundColor(.background)
            .background(Color.primary)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .animation(.default, value: selectedCurrencyType)
        .disabled(doesUserWalletHaveInsufficientFunds)
    }
    
    func tappedMaxEthAmount() {
        let maxEthAmount = selectedCurrencyType == .fiat ?
        ethPrice.convertEthToFiat(userWalletEth, fiatType: selectedFiatType) :
        userWalletEth
        selectedAmount = maxEthAmount
    }
    
    func tappedSwitchSelectedCurrency() {
        // Toggle selected currency
        selectedCurrencyType = selectedCurrencyType == .eth ? .fiat : .eth
        // Rotate button
        switchSelectedCurrencyButtonRotation += 180
        // Convert selected amount
        let convertedToEth = ethPrice.convertFiatToEth(selectedAmount, fiatType: selectedFiatType)
        let convertedToFiat = ethPrice.convertEthToFiat(selectedAmount, fiatType: selectedFiatType)
        selectedAmount = selectedCurrencyType == .eth ? convertedToEth : convertedToFiat
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(EthPrice())
    }
}

// Use with @FocusState onChange to select all in TextField
func sendSelectAllUpResponderChain() {
    DispatchQueue.main.async {
        UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
    }
}
