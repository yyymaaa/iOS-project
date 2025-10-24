import SwiftUI
import FirebaseCore

struct MealRow: View {
    let meal: Meal
    @EnvironmentObject var cartManager: CartManager
    @State private var quantity: Int = 1
    @State private var showConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Meal image
            AsyncImage(url: URL(string: meal.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 180)
            .clipped()
            .cornerRadius(12)

            // Meal details
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)

                Text(meal.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Text("Ksh \(Int(meal.discountPrice))")
                        .foregroundColor(.green)
                        .bold()
                    if meal.discountPrice < meal.price {
                        Text("Ksh \(Int(meal.price))")
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
            }

            // Quantity and Add button
            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Text("-")
                            .font(.title2)
                            .foregroundColor(.green)
                    }

                    Text("\(quantity)")
                        .font(.body)
                        .frame(width: 24)

                    Button(action: { quantity += 1 }) {
                        Text("+")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Add to Cart button
                Button(action: {
                    cartManager.addToCart(meal, quantity: quantity)
                    showConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showConfirmation = false
                    }
                }) {
                    Text("Add to Cart")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                }
            }
            .padding(.top, 6)

            Divider()
                .padding(.top, 10)
        }
        .padding(.horizontal)
        .overlay(
            // Confirmation message
            Group {
                if showConfirmation {
                    Text("Added to cart")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showConfirmation)
                        .offset(y: -20)
                }
            },
            alignment: .topTrailing
        )
    }
}
