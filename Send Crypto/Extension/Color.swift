//
//  Color.swift
//  Send Crypto
//
//  Created by Ryan Forsyth on 2023-09-08.
//
// https://stackoverflow.com/questions/60672626/swiftui-get-the-dynamic-background-color-dark-mode-or-light-mode

import SwiftUI

public extension Color {
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    static let customBG = Color("custom-bg-color")
}
