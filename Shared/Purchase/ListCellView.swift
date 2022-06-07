/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for an individual Car or Subscription product that shows a buy button when displayed
    within the store, but not when displayed in the MyCars view.
*/

import SwiftUI
import StoreKit

struct ListCellView: View {
    @EnvironmentObject var store: Store
    @State var isPurchased: Bool = false
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @AppStorage("subscribed") private var subscribed = false
    let product: Product
    let purchasingEnabled: Bool

   

    init(product: Product, purchasingEnabled: Bool = true) {
        self.product = product
        self.purchasingEnabled = purchasingEnabled
    }

    var body: some View {
        VStack{
         
        HStack {
           
            
            if purchasingEnabled {
               
                buyButton
                    .buttonStyle(.borderedProminent)
                    .tint(Color.accentColor)
                    //.disabled(isPurchased)
                    .padding()
            } else {
                productDetail
            }
        }
            
        }
       
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
    }

    @ViewBuilder
    var productDetail: some View {
        if product.type == .autoRenewable {
            VStack(alignment: .leading) {
               
                Text("Free 1 week trial")
                    .bold()
                Text("Cancel anytime")
                
                //Text(product.description)
                   // .font(.footnote)
            }
        } else {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .bold()
            Text(product.description)
            }
            
        }
    }

    func subscribeButton(_ subscription: Product.SubscriptionInfo) -> some View {
        let unit: String
        let plural = 1 < subscription.subscriptionPeriod.value
            switch subscription.subscriptionPeriod.unit {
        case .day:
            unit = plural ? "\(subscription.subscriptionPeriod.value) days" : "day"
        case .week:
            unit = plural ? "\(subscription.subscriptionPeriod.value) weeks" : "week"
        case .month:
            unit = plural ? "\(subscription.subscriptionPeriod.value) months" : "month"
        case .year:
            unit = plural ? "\(subscription.subscriptionPeriod.value) years" : "year"
        @unknown default:
            unit = "period"
        }

        return HStack {
            Text(product.displayPrice)
                .foregroundColor(.white)
                .font(.system(size: 14))
               
                
            Divider()
                .background(Color.white)
            Text(unit)
                .foregroundColor(.white)
                .font(.system(size: 12))
               
        }
        .frame(width: 140, height: 20, alignment: .center)
       
    }

    var buyButton: some View {
        Button(action: {
            Task {
                await buy()
            }
        }) {
            if isPurchased {
                
                Text("You all set")
                    .bold()
                
                    .padding()
            } else {
               
                    Text("\(product.displayPrice)")
                   
                        .foregroundColor(.white)
                        .bold()
                        .padding(.horizontal)
                       
                
            }
        }
       
        .frame(width: 230, height: 20, alignment: .center)
        .onAppear {
            Task {
                isPurchased = (try? await store.isPurchased(product.id)) ?? false
            }
        }
        .onChange(of: store.purchasedIdentifiers) { identifiers in
            Task {
                isPurchased = identifiers.contains(product.id)
                subscribed = isPurchased
            }
        }
    }

    func buy() async {
        do {
            if try await store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}
