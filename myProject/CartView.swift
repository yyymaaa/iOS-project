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
                            Text(item.meal.name)
                            Spacer()
                            Text("x\(item.quantity)")
                            Text("Ksh \(Int(item.meal.discountPrice * Double(item.quantity)))")
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let item = cartManager.cartItems[index]
                            cartManager.removeFromCart(item.meal)
                        }
                    }
                }

                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("Ksh \(Int(cartManager.totalAmount()))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                Button(action: {
                    // Proceed to checkout screen (later)
                    print("Proceeding to payment...")
                }) {
                    Text("Proceed to Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}
