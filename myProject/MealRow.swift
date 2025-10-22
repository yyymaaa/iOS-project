import SwiftUI
import FirebaseCore


struct MealRow: View {
    let meal: Meal
    @EnvironmentObject var cartManager: CartManager
    @State private var quantity: Int = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Meal image
            AsyncImage(url: URL(string: meal.imageUrl)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 180)
            .cornerRadius(15)

            // Meal info
            VStack(alignment: .leading, spacing: 6) {
                Text(meal.name)
                    .font(.headline)

                Text(meal.description)
                    .foregroundColor(.gray)
                    .font(.subheadline)

                HStack {
                    Text("Ksh \(Int(meal.discountPrice))")
                        .foregroundColor(.green)
                    if meal.discountPrice < meal.price {
                        Text("Ksh \(Int(meal.price))")
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
                .font(.subheadline)
            }

            // Quantity and Add to Cart controls
            HStack {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }

                Text("\(quantity)")
                    .frame(width: 30)
                    .padding(.horizontal, 6)

                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }

                Spacer()

                Button(action: {
                    cartManager.addToCart(meal, quantity: quantity)
                }) {
                    Text("Add to Cart")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
