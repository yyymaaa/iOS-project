import Foundation
import FirebaseFirestore

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
