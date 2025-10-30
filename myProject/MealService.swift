import Foundation
import FirebaseFirestore


class MealService: ObservableObject {
    @Published var meals: [Meal] = []
    private let db = Firestore.firestore()

    // ✅ Fetch meals for a restaurant
    func fetchMeals(for restaurantID: String) {
        db.collection("meals")
            .whereField("restaurantID", isEqualTo: restaurantID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching meals: \(error.localizedDescription)")
                    return
                }

                self.meals = snapshot?.documents.compactMap { document in
                    try? document.data(as: Meal.self)
                } ?? []
            }
    }

    // ✅ Add new meal
    func addMeal(_ meal: Meal, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("meals").addDocument(from: meal)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // ✅ Update existing meal
    func updateMeal(_ meal: Meal) {
        guard let id = meal.id else { return }
        do {
            try db.collection("meals").document(id).setData(from: meal)
        } catch {
            print("Error updating meal: \(error.localizedDescription)")
        }
    }

    // ✅ Delete a meal
    func deleteMeal(_ meal: Meal) {
        guard let id = meal.id else { return }
        db.collection("meals").document(id).delete { error in
            if let error = error {
                print("Error deleting meal: \(error.localizedDescription)")
            }
        }
    }
}
