import Foundation

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []

    func addToCart(_ meal: Meal, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.meal.id == meal.id }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(meal: meal, quantity: quantity)
            cartItems.append(newItem)
        }
    }

    func removeFromCart(_ meal: Meal) {
        cartItems.removeAll { $0.meal.id == meal.id }
    }

    func totalAmount() -> Double {
        cartItems.reduce(0) { $0 + ($1.meal.discountPrice * Double($1.quantity)) }
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let meal: Meal
    var quantity: Int
}
