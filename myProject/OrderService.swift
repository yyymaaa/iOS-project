import FirebaseFirestore


class OrderService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var orders: [Order] = []

    func fetchOrders(for mealIDs: [String]) {
        guard !mealIDs.isEmpty else {
            print("No meal IDs, skipping orders fetch.")
            return
        }

        db.collection("orders")
            .whereField("mealID", in: mealIDs)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }
                self.orders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }
}
