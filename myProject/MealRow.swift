import SwiftUI
import FirebaseCore



struct MealRow: View {
    let meal: Meal
    @EnvironmentObject var cartManager: CartManager
    @State private var showAddedAnimation = false
    
    var body: some View {
        HStack(spacing: 16) {
            mealImage
            mealDetails
            Spacer()
            addButton
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .luxBurgundy.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var mealImage: some View {
        AsyncImage(url: URL(string: meal.imageUrl)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.luxBurgundy.opacity(0.1)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.title3)
                        .foregroundColor(.luxBurgundy.opacity(0.5))
                )
        }
        .frame(width: 90, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var mealDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.name)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
                .lineLimit(2)
            
            Text(meal.description)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("KSh \(String(format: "%.0f", meal.discountPrice))")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.luxBurgundy)
                
                if meal.discountPrice < meal.price {
                    Text("KSh \(String(format: "%.0f", meal.price))")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .strikethrough()
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            cartManager.addToCart(meal, quantity: 1)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showAddedAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showAddedAnimation = false
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy, .luxDeepBurgundy],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: .luxBurgundy.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: showAddedAnimation ? "checkmark" : "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(showAddedAnimation ? 1.2 : 1.0)

    }
}
