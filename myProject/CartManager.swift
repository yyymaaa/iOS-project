import Foundation
import SwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var confirmationMessage: String? = nil

    func addToCart(_ meal: Meal, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.meal.id == meal.id }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(meal: meal, quantity: quantity)
            cartItems.append(newItem)
        }

        // Show confirmation
        confirmationMessage = "\(meal.name) added to cart!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.confirmationMessage = nil
        }
    }

    func increaseQuantity(for meal: Meal) {
        if let index = cartItems.firstIndex(where: { $0.meal.id == meal.id }) {
            cartItems[index].quantity += 1
        }
    }

    func decreaseQuantity(for meal: Meal) {
        if let index = cartItems.firstIndex(where: { $0.meal.id == meal.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                removeFromCart(meal)
            }
        }
    }

    func removeFromCart(_ meal: Meal) {
        cartItems.removeAll { $0.meal.id == meal.id }
    }

    func totalAmount() -> Double {
        cartItems.reduce(0) { $0 + ($1.meal.discountPrice * Double($1.quantity)) }
    }
    
    func clearCart() {
            withAnimation(.spring()) {
                cartItems.removeAll()
            }
        }
}

struct CartItem: Identifiable {
    let id = UUID()
    let meal: Meal
    var quantity: Int
}
