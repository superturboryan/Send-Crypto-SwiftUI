//
//  RootView.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var crypto: Crypto
    
    @State var amountToSend: String = "$1 958"
    
    @State var selectedFiat: FiatType = .usd
    @State var isPresentingFiatSelector = false
    
    @FocusState var amountIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            Text("Send Ethereum")
                .font(.system(size: 32, weight: .medium))
                .fullWidth(.leading)
            
            VStack(alignment: .leading, spacing: 16) {
                
                fiatCryptoConversionView
                
                networkFeesView
            }
            
            Spacer()
            
            sendButton
        }
        .padding([.top, .horizontal], 32)
        .padding(.bottom, 16)
        .task {
            try? await crypto.load()
            print("Loaded")
        }
        .fullWidthAndHeight()
        .background(Color.customBG)
        .onTapGesture {
            // Tap anywhere on bg to dismiss keyboard/focus for TextField
            amountIsFocused = false
        }
        .sheet(isPresented: $isPresentingFiatSelector) {
            let figmaSheetHeight: CGFloat = 488
            FiatSelectorView(selection: $selectedFiat)
                .presentationDetents([.height(figmaSheetHeight - 20)])
                .presentationDragIndicator(.visible)
        }
    }
    
    var fiatCryptoConversionView: some View {
        VStack(spacing: 8) {
            
            // Header
            HStack {
                Spacer()
                // Max user can send according to their balance
                Text("Max 3 450 ETH")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(height: 16) // Line height 16 in Figma
            }
            
            HStack(alignment: .top) {
                // Fiat-Crypto conversion amounts
                VStack(alignment: .leading, spacing: 3) {
                    
                    // Top amount
                    TextField("Amount", text: $amountToSend)
                        .font(.system(size: 20, weight: .medium))
                        .frame(height: 24)
                        .keyboardType(.numberPad)
                        .focused($amountIsFocused)
                        // TODO: Filter $amount in onReceive
                    
                    // Bottom amount
                    Text("1.2 ETH")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(height: 16)
                }
                Spacer()
                // Fiat button
                Button { isPresentingFiatSelector = true } label: {
                    HStack(spacing: 8) {
                        // Fiat type image
                        selectedFiat.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                            .background(.white) // Assets have clear bg
                            .clipShape(Circle()) // Assets are square
                        // Fiat type label
                        Text(selectedFiat.rawValue.uppercased())
                        // Down chevron
                        Image(systemName: "chevron.down")
                    }
                    .fontWeight(.medium) // Applies to text and chevron
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 40)
        .padding(.trailing, 18)
        .padding(.vertical, 8)
        .frame(height: 84)
        .roundedCornerBorder(cornerRadius: 8, color: .secondary.opacity(0.4), width: 2)
        .overlay(  // Place after padding and rounded corner
            fiatCryptoSwitchButton,
            alignment: .leading
        )
    }
    
    @ViewBuilder
    var fiatCryptoSwitchButton: some View {
        let size: CGFloat = 50
        ZStack {
            Color.white
            Image.exchange
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .frame(width: size, height: size)
        .clipped()
        .overlay(Circle().stroke(.secondary.opacity(0.2), lineWidth: 2))
        .offset(x: -(size / 2))
        .onTapGesture {
            // Tapped switch
        }
    }
    
    var networkFeesView: some View {
        HStack(spacing: 4) {
            Image(systemName: "info.circle")
            Text("Est. Network fees: ~0.0012 ETH")
                .font(.system(size: 12, weight: .medium))
        }
    }
    
    var sendButton: some View {
        // Many different ways to skin a button
        Text("Send $1 958 of ETH")
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 16)
            .fullWidth()
            .foregroundColor(.background)
            .background(Color.primary)
            .cornerRadius(4)
            .onTapGesture {
                // Tapped send
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(Crypto())
    }
}
