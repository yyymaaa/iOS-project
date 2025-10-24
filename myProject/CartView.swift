import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        VStack(spacing: 20) {
            
            // --- Title ---
            VStack(spacing: 6) {
                Text("Your Cart")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 3)
                    .cornerRadius(2)
            }
            .padding(.top, 16)
            
            if cartManager.cartItems.isEmpty {
                Spacer()
                Text("Your cart is empty.")
                    .foregroundColor(.gray)
                    .font(.headline)
                Spacer()
            } else {
                // --- Cart List ---
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(cartManager.cartItems) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.meal.name)
                                            .font(.headline)
                                        Text("Ksh \(Int(item.meal.discountPrice)) each")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    // --- Quantity Controls ---
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            cartManager.decreaseQuantity(for: item.meal)
                                        }) {
                                            Text("-")
                                                .font(.title2)
                                                .foregroundColor(.green)
                                        }

                                        Text("\(item.quantity)")
                                            .font(.body)
                                            .frame(width: 24)

                                        Button(action: {
                                            cartManager.increaseQuantity(for: item.meal)
                                        }) {
                                            Text("+")
                                                .font(.title2)
                                                .foregroundColor(.green)
                                        }
                                    }

                                    // Delete icon 
                                    Button(action: {
                                        cartManager.removeFromCart(item.meal)
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.green)
                                            .padding(.leading, 8)
                                    }
                                }

                                // Item total
                                Text("Ksh \(Int(item.meal.discountPrice * Double(item.quantity)))")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }

                // --- Total Section ---
                VStack(spacing: 16) {
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("Ksh \(Int(cartManager.totalAmount()))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)

                    // --- Checkout Button ---
                    Button(action: {
                        print("Proceeding to payment...")
                    }) {
                        Text("Proceed to Checkout")
                            .font(.headline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
    }
}
