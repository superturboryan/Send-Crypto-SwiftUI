//
//  FiatSelectorView.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

struct FiatSelectorView: View {
    
    var selectedAmount: Double
    @Binding var selectedFiat: FiatType
    
    @EnvironmentObject var ethPrice: EthPrice
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Displayed currency")
                .font(.system(size: 20, weight: .medium))
                .fullWidth(.leading)
            
            fiatTypesList
            
            footer
        }
        .edgesIgnoringSafeArea([.bottom])
        .padding(.bottom, 16)
        .padding([.horizontal, .top], 32)
        .edgesIgnoringSafeArea([.bottom])
        .fullWidthAndHeight()
        .background(Color.customBG)
    }
    
    var fiatTypesList: some View {
        VStack(spacing: 16) {
            ForEach(FiatType.allCases, id: \.self) { type in
                fiatCell(type)
                    .onTapGesture {
                        selectedFiat = type
                        dismiss()
                    }
            }
        }
    }
    
    @ViewBuilder
    func fiatCell(_ type: FiatType) -> some View {
        HStack(spacing: 16) {
            type.image
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(type.monetaryUnit + "s")
                    .font(.system(size: 20, weight: .medium))
                    .frame(height: 24)
                Text(type.rawValue.uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(height: 16)
            }
            
            Spacer(minLength: 20)
            
            // Not clear from Figma what these two values correspond to when ETH is selected?
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(ethPrice.convertFiatToEth(selectedAmount, fiatType: type))")
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 24)
                Text("\(type.symbol)\(String(format: "%.2f", selectedAmount))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(height: 16)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .fullWidth()
        .background(Color.white)
        .roundedCornerBorder(
            cornerRadius: 4,
            color: selectedFiat == type ? .black : .secondary.opacity(0.2),
            width: selectedFiat == type ? 2 : 1
        )
    }
    
    var footer: some View {
        // Why does the footer use similar styling to the selectable cells?
        // UX might be better if it wasn't the same size/didn't have border
        HStack(spacing: 16) {
            Image(systemName: "info.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(2)
                .frame(width: 24, height: 24)
            
            Text("The currency is for information only. \nYou're still sending ETH.")
                .lineLimit(2)
                .font(.system(size: 13, weight: .medium)) // Size 13 in Figma? Too many font sizes...
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .fullWidth()
        .roundedCornerBorder(cornerRadius: 4, color: .black, width: 1)
    }
}

struct FiatSelectorView_Previews: PreviewProvider {
    @State static var fiat = FiatType.usd
    static var previews: some View {
        FiatSelectorView(selectedAmount: 20, selectedFiat: $fiat)
            .environmentObject(EthPrice())
    }
}
