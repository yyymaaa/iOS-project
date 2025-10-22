import SwiftUI
import FirebaseFirestore

struct MealView: View {
    let restaurant: Restaurant
    @StateObject private var mealVM = MealViewModel()
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text("\(restaurant.name) Menu")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                if mealVM.meals.isEmpty {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading meals...")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                } else {
                    ForEach(mealVM.meals) { meal in
                        MealRow(meal: meal)
                            .environmentObject(cartManager)
                    }
                }
            }
            .padding(.bottom, 80)
        }
        .onAppear {
            mealVM.fetchMeals(for: restaurant.id ?? "")
        }
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
