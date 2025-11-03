import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var items: [OrderItem]
    var totalAmount: Double
    var paymentMethod: String
    var status: String
    var customerID: String
    var customerEmail: String?
    var customerName: String?
    var restaurantID: String
    var createdAt: Date
    var orderNumber: String
    
    // this is a computed property for backward compatibility
    var mealName: String? {
        return items.first?.mealName
    }
    
    var amountPaid: Double {
        return totalAmount
    }
}

struct OrderItem: Identifiable, Codable {
    var id = UUID().uuidString
    var mealID: String
    var mealName: String
    var quantity: Int
    var price: Double
}

struct Meal: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var imageUrl: String
    var price: Double
    var discountPrice: Double
    var restaurantID: String
    var isAvailable: Bool
    var createdAt: Date
}

struct Restaurant: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var location: String
    var imageUrl: String
    var ownerID: String
}

struct User {
    var uid: String
    var email: String
    var role: String
    var restaurantID: String? = nil
}
