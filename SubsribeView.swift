//
//  SubsribeView.swift
//  Poems (iOS)
//
//  Created by Tema Sysoev on 25.09.2021.
//

import SwiftUI
import StoreKit

struct SubscribeView: View {
    @EnvironmentObject var store: Store

    @State var currentSubscription: Product?
    @State var status: Product.SubscriptionInfo.Status?
    @AppStorage("subscribed") private var subscribed = false
    
    var userAccentColor: String
    var availableSubscriptions: [Product] {
        store.subscriptions.filter { $0.id != currentSubscription?.id }
    }

    var body: some View {
                VStack(alignment: .center){
          
        Image("SubscribeImage")
            .resizable()
            .scaledToFit()
            .padding()
          Spacer()
           
        Text("Thanks for using Poems 2!")
            .bold()
            .padding()
        Text("If you wish, you can unlock an offline library, themes, ability to add yours poems, 3 learning modes and video recording with one-time in-app purchase shared across your devices")
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        Group {
            if let currentSubscription = currentSubscription {
                Section(header: Text("My Subscription")) {
                   ListCellView(product: currentSubscription, purchasingEnabled: false)
                        .padding()
                    if let status = status {
                        StatusInfoView(product: currentSubscription,
                                        status: status)
                    }
                }
                #if os(iOS)
                .listStyle(GroupedListStyle())
                #endif
            }

            Section(header: Text("")) {
               
                ForEach(store.onTimePurchase, id: \.id) { v in
                   
                    ListCellView(product: v)
                        .padding(.all, 5)
                }
               
               
            }
#if os(iOS)
            .listStyle(GroupedListStyle())
            #endif
            Button(action: {
                if (SKPaymentQueue.canMakePayments()) {
                  SKPaymentQueue.default().restoreCompletedTransactions()
                }
                func paymentQueue(_ queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
                  print("Received Payment Transaction Response from Apple");
                  for transaction in transactions {
                   switch transaction.transactionState {
                    case .purchased, .restored:
                      print("Purchased purchase/restored")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        subscribed = true
                      break
                    case .failed:
                      print("Purchased Failed")
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                      break
                    default:
                      print("default")
                      break
                    }
                  }
                }
                
            }, label: {
                Text("Restore")
            })
                
            
            
               
        }
        .onAppear {
            Task {
                //When this view appears, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        .onChange(of: store.purchasedIdentifiers) { _ in
            Task {
                //When `purchasedIdentifiers` changes, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        }
        
#if os(macOS)
                .frame(minWidth: 400, maxWidth: 400, minHeight: 400, maxHeight: 400)
        
#endif
    }

    @MainActor
    func updateSubscriptionStatus() async {
        do {
            //This app has only one subscription group so products in the subscriptions
            //array all belong to the same group. The statuses returned by
            //`product.subscription.status` apply to the entire subscription group.
            guard let product = store.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }

            var highestStatus: Product.SubscriptionInfo.Status? = nil
            var highestProduct: Product? = nil

            //Iterate through `statuses` for this subscription group and find
            //the `Status` with the highest level of service which isn't
            //expired or revoked.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try store.checkVerified(status.renewalInfo)

                    guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }

                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }

                    let highestTier = store.tier(for: currentProduct.id)
                    let newTier = store.tier(for: renewalInfo.currentProductID)

                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }

            status = highestStatus
            currentSubscription = highestProduct
        } catch {
            print("Could not update subscription status \(error)")
        }
    }
}

struct SubsribeView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeView(userAccentColor: "")
    }
}
