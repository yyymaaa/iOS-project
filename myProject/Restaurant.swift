import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var location: String
    var imageURL: String
    var ownerID: String
    var createdAt: Date
}
