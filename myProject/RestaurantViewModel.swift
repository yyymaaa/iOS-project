import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    private var db = Firestore.firestore()

    func fetchRestaurants() {
        db.collection("restaurants").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching restaurants: \(error.localizedDescription)")
                return
            }

            self.restaurants = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Restaurant.self)
            } ?? []
        }
    }
}
