/*
 This is an extension for the Color class in SwiftUI.
 This is particularly useful for our onboarding screens and other UI elements
 where we need precise color control and consistency with design specifications.
 Created by: Nazanin Mahmoudi
 */

import SwiftUI

extension Color {
    static func hex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}
