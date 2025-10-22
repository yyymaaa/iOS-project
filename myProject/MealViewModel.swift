import Foundation
import FirebaseFirestore

class MealViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    private var db = Firestore.firestore()

    func fetchMeals(for restaurantID: String) {
        db.collection("meals")
            .whereField("restaurantID", isEqualTo: restaurantID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching meals: \(error.localizedDescription)")
                    return
                }

                self.meals = snapshot?.documents.compactMap { doc -> Meal? in
                    try? doc.data(as: Meal.self)
                } ?? []
            }
    }
}
