import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var mealID: String?
    var mealName: String?
    var amountPaid: Double
    var paymentMethod: String?
    var status: String?
    var userID: String?
    var restaurantID: String?
    var createdAt: Date
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
