//
//  View.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//

import SwiftUI

extension View {
    func fullWidth(_ alignment: Alignment = .center) -> some View {
        self.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
    
    func fullWidthAndHeight() -> some View {
        self.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    func size(_ size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    func roundedCornerBorder(cornerRadius: CGFloat, color: Color, width: CGFloat) -> some View {
        self.cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius).stroke(color, lineWidth: width)
            )
    }
}
