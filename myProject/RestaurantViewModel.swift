import SwiftUI
import FirebaseFirestore

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    
    private var db = Firestore.firestore()
    
    func fetchRestaurants() {
        db.collection("restaurants").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching restaurants:", error.localizedDescription)
                self.restaurants = []
                return
            }
            
            self.restaurants = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return Restaurant(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    location: data["location"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? "",
                    ownerID: data["ownerID"] as? String ?? ""
                )
            } ?? []
        }
    }
}
