import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class RestaurantViewModel: ObservableObject {
    @Published var restaurants = [Restaurant]()
    private var db = Firestore.firestore()

    func fetchRestaurants() {
        db.collection("restaurants").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents found in Firestore.")
                return
            }

            self.restaurants = documents.map { doc in
                let data = doc.data()
                return Restaurant(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    location: data["location"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? "", 
                    ownerID: data["ownerID"] as? String ?? ""
                )
            }
        }
    }
}

