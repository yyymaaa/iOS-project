import SwiftUI
import FirebaseFirestore

struct MealView: View {
    let restaurant: Restaurant
    @StateObject private var mealVM = MealViewModel()
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // --- Centered Restaurant Title ---
                VStack(spacing: 6) {
                    Text(restaurant.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 80, height: 3)
                        .cornerRadius(2)
                }
                .padding(.top, 10)

                // --- Meals Section ---
                if mealVM.meals.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading meals...")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(mealVM.meals) { meal in
                            MealRow(meal: meal)
                                .environmentObject(cartManager)
                        }
                    }
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color(.systemGroupedBackground)) // soft gray background
        .onAppear {
            mealVM.fetchMeals(for: restaurant.id ?? "")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
