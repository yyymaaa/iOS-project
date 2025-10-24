import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Cart")
                .font(.largeTitle)
                .bold()
                .padding()

            if cartManager.cartItems.isEmpty {
                Text("Your cart is empty.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(cartManager.cartItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.meal.name)
                                    .font(.headline)
                                Text("Ksh \(Int(item.meal.discountPrice)) each")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Quantity controls
                            HStack(spacing: 15) {
                                Button(action: {
                                    cartManager.decreaseQuantity(for: item.meal)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.green)
                                }

                                Text("\(item.quantity)")
                                    .font(.headline)
                                    .frame(width: 25)

                                Button(action: {
                                    cartManager.increaseQuantity(for: item.meal)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }

                            // Delete icon
                            Button(action: {
                                cartManager.removeFromCart(item.meal)
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.green)
                            }

                            // Item total
                            Text("Ksh \(Int(item.meal.discountPrice * Double(item.quantity)))")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }

                // Total section
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("Ksh \(Int(cartManager.totalAmount()))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                // Checkout button
                Button(action: {
                    print("Proceeding to payment...")
                }) {
                    Text("Proceed to Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}
