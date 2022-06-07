/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The style of the product buttons displayed in the store view.
*/

import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool
    private var userAccentColor = "pattern6Color"
    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color(userAccentColor)
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
           
            .padding()
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        
    }
}
