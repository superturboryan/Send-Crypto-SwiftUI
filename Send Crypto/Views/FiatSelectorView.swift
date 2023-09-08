//
//  FiatSelectorView.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

struct FiatSelectorView: View {
    
    @Binding var selection: FiatType
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Displayed currency")
                .font(.system(size: 20, weight: .medium))
                .fullWidth(.leading)
            
            // Fiat type list
            VStack(spacing: 16) {
                ForEach(FiatType.allCases, id: \.self) { type in
                    fiatCell(type)
                    .onTapGesture {
                        selection = type
                        dismiss()
                    }
                }
            }
            
            // Footer
            HStack(spacing: 16) {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
                    .frame(width: 24, height: 24)
                
                Text("The currency is for information only. \nYou're still sending ETH.")
                    .lineLimit(2)
                    .font(.system(size: 13, weight: .medium)) // Size 13 in Figma?
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .fullWidth()
            .roundedCornerBorder(cornerRadius: 4, color: .black, width: 1)
        }
        .edgesIgnoringSafeArea([.bottom])
        .padding(.bottom, 16)
        .padding([.horizontal, .top], 32)
        .edgesIgnoringSafeArea([.bottom])
        .fullWidthAndHeight()
        .background(Color.customBG)
    }
    
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
            
            VStack(alignment: .trailing, spacing: 0) {
                Text("234.50")
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 24)
                Text("$67 860")
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
            color: selection == type ? .black : .secondary.opacity(0.2),
            width: selection == type ? 2 : 1
        )
    }
}

struct FiatSelectorView_Previews: PreviewProvider {
    @State static var fiat = FiatType.usd
    static var previews: some View {
        FiatSelectorView(selection: $fiat)
    }
}
