import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Charts

struct RestaurantDashboardView: View {
    @State private var selectedTab = 0
    @State private var restaurant: Restaurant?
    @State private var meals: [Meal] = []
    @State private var orders: [Order] = []
    @State private var newMealName = ""
    @State private var newMealDescription = ""
    @State private var newMealPrice = ""
    @State private var newMealDiscountPrice = ""
    @State private var newMealImageUrl = ""
    @State private var newMealAvailable = true
    @State private var editName = ""
    @State private var editLocation = ""
    @State private var editImageUrl = ""
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var authVM: AuthViewModel
    private var db = Firestore.firestore()
    
    // Luxury Color Palette
    private let burgundy = Color(red: 0.5, green: 0.13, blue: 0.13)
    private let deepBurgundy = Color(red: 0.35, green: 0.09, blue: 0.09)
    private let lightBurgundy = Color(red: 0.7, green: 0.2, blue: 0.2)
    private let cream = Color(red: 0.98, green: 0.97, blue: 0.95)
    private let gold = Color(red: 0.85, green: 0.65, blue: 0.13)
    
    var body: some View {
        NavigationView {
            ZStack {
                cream.ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    ordersTab.tabItem {
                        Label("Orders", systemImage: "doc.text")
                    }.tag(0)
                    
                    menuTab.tabItem {
                        Label("Menu", systemImage: "list.bullet.rectangle")
                    }.tag(1)
                    
                    profileTab.tabItem {
                        Label("Profile", systemImage: "building.2")
                    }.tag(2)
                    
                    analyticsTab.tabItem {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    }.tag(3)
                }
                .accentColor(burgundy)
            }
            .navigationTitle(restaurant?.name ?? "Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                Button(action: logout) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(burgundy)
                }
            )

            .onAppear(perform: loadRestaurantData)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Orders Tab
    private var ordersTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                if orders.isEmpty {
                    emptyStateView(icon: "cart", message: "No orders yet")
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(orders) { order in
                            orderCard(order)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(cream)
    }
    
    private func orderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Show first item name + count of additional items
                if let firstItem = order.items.first {
                    Text("\(firstItem.mealName)\(order.items.count > 1 ? " + \(order.items.count - 1) more" : "")")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(deepBurgundy)
                } else {
                    Text("Order #\(order.orderNumber)")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(deepBurgundy)
                }
                Spacer()
                statusBadge(order.status)
            }
            
            Divider().background(burgundy.opacity(0.2))
            
            // Customer Information - NEW SECTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Customer Information")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(burgundy.opacity(0.8))
                
                HStack {
                    Label(order.customerName ?? "Customer", systemImage: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(deepBurgundy)
                    
                    Spacer()
                    
                    // Clickable phone number
                    if let phone = order.customerPhone, !phone.isEmpty {
                        Button(action: {
                            callCustomer(phone: phone)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 12))
                                Text(phone)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(burgundy)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            
            HStack {
                Label("KSh \(String(format: "%.2f", order.totalAmount))", systemImage: "creditcard")
                    .font(.system(size: 14))
                    .foregroundColor(burgundy.opacity(0.8))
                Spacer()
                Text(order.orderNumber)
                    .font(.system(size: 11, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            if order.status != "delivered" && order.status != "completed" {
                HStack(spacing: 12) {
                    if order.status == "pending" {
                        luxuryButton(title: "Mark Ready", color: burgundy) {
                            updateOrderStatus(order, to: "ready")
                        }
                    }
                    if order.status == "ready" {
                        luxuryButton(title: "Mark Delivered", color: deepBurgundy) {
                            updateOrderStatus(order, to: "delivered")
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: burgundy.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private func statusBadge(_ status: String) -> some View {
        Text(status.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                status == "pending" ? gold :
                status == "ready" ? burgundy : deepBurgundy
            )
            .cornerRadius(8)
    }
    
    // MARK: - Menu Tab
    private var menuTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !meals.isEmpty {
                    LazyVStack(spacing: 16) {
                        ForEach(meals) { meal in
                            mealCard(meal)
                        }
                    }
                }
                
                addMealSection
            }
            .padding()
        }
        .background(cream)
    }
    
    private func mealCard(_ meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(meal.name)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(deepBurgundy)
                    
                    Text(meal.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                AsyncImage(url: URL(string: meal.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    burgundy.opacity(0.1)
                }
                .frame(width: 70, height: 70)
                .cornerRadius(12)
            }
            
            Divider().background(burgundy.opacity(0.2))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KSh \(String(format: "%.2f", meal.discountPrice))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(burgundy)
                    if meal.discountPrice < meal.price {
                        Text("KSh \(String(format: "%.2f", meal.price))")
                            .font(.system(size: 13))
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: .constant(meal.isAvailable))
                    .labelsHidden()
                    .tint(burgundy)
                    .disabled(true)
                
                Button(action: { toggleMealAvailability(meal) }) {
                    Text(meal.isAvailable ? "Available" : "Unavailable")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(meal.isAvailable ? burgundy : .gray)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: burgundy.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var addMealSection: some View {
        VStack(spacing: 20) {
            Text("Add New Item")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(deepBurgundy)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            luxuryTextField(title: "Name", text: $newMealName)
            luxuryTextField(title: "Description", text: $newMealDescription)
            
            HStack(spacing: 12) {
                luxuryTextField(title: "Price", text: $newMealPrice)
                luxuryTextField(title: "Discount", text: $newMealDiscountPrice)
            }
            
            luxuryTextField(title: "Image URL", text: $newMealImageUrl)
            
            HStack {
                Text("Available")
                    .font(.system(size: 15))
                    .foregroundColor(burgundy)
                Spacer()
                Toggle("", isOn: $newMealAvailable)
                    .tint(burgundy)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            luxuryButton(title: "Add to Menu", color: burgundy, action: addMeal)
        }
        .padding(24)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(burgundy.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Profile Tab
    private var profileTab: some View {
        ScrollView {
            VStack(spacing: 28) {
                if let r = restaurant {
                    AsyncImage(url: URL(string: editImageUrl.isEmpty ? r.imageUrl : editImageUrl)) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        burgundy.opacity(0.2)
                    }
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    .shadow(color: burgundy.opacity(0.15), radius: 16, x: 0, y: 8)
                    
                    VStack(spacing: 20) {
                        Text("Restaurant Profile")
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundColor(deepBurgundy)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        luxuryTextField(title: "Name", text: $editName)
                            .onAppear { editName = r.name }
                        
                        luxuryTextField(title: "Location", text: $editLocation)
                            .onAppear { editLocation = r.location }
                        
                        luxuryTextField(title: "Image URL", text: $editImageUrl)
                            .onAppear { editImageUrl = r.imageUrl }
                        
                        luxuryButton(title: "Save Changes", color: burgundy, action: updateRestaurantProfile)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: burgundy.opacity(0.08), radius: 12, x: 0, y: 4)
                }
            }
            .padding()
        }
        .background(cream)
    }
    
    // MARK: - Analytics Tab
    private var analyticsTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                if orders.isEmpty {
                    emptyStateView(icon: "chart.bar.xaxis", message: "No sales data yet")
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Sales Overview")
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                            .foregroundColor(deepBurgundy)
                        
                        HStack(spacing: 20) {
                            statCard(title: "Total Orders", value: "\(orders.count)", icon: "cart")
                            statCard(title: "Revenue", value: "KSh \(String(format: "%.0f", orders.reduce(0) { $0 + $1.totalAmount }))", icon: "banknote")
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Sales")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(burgundy)
                            
                            Chart {
                                ForEach(groupOrdersByDate(), id: \.0) { date, total in
                                    BarMark(
                                        x: .value("Date", date, unit: .day),
                                        y: .value("Sales", total)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [lightBurgundy, burgundy],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .frame(height: 280)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel()
                                        .foregroundStyle(burgundy.opacity(0.7))
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisValueLabel()
                                        .foregroundStyle(burgundy.opacity(0.7))
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: burgundy.opacity(0.08), radius: 12, x: 0, y: 4)
                    }
                }
            }
            .padding()
        }
        .background(cream)
    }
    
    private func callCustomer(phone: String) {
        let tel = "tel://"
        let formattedNumber = tel + phone
        guard let url = URL(string: formattedNumber) else { return }
        
        #if targetEnvironment(simulator)
        // Simulator can't make calls, show alert instead
        alertMessage = "Calling \(phone) - This would open the phone app on a real device"
        showAlert = true
        #else
        UIApplication.shared.open(url)
        #endif
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(gold)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(deepBurgundy)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: burgundy.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Reusable Components
    private func luxuryTextField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(burgundy.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1)
            
            TextField("", text: text)
                .font(.system(size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(burgundy.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    private func luxuryButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private func emptyStateView(icon: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(burgundy.opacity(0.3))
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    // MARK: - Firestore Functions
    private func loadRestaurantData() {
        guard let uid = authVM.userSession?.uid else { return }
        db.collection("restaurants").whereField("ownerID", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            guard let doc = snapshot?.documents.first else { return }
            let data = doc.data()
            restaurant = Restaurant(
                id: doc.documentID,
                name: data["name"] as? String ?? "",
                location: data["location"] as? String ?? "",
                imageUrl: data["imageUrl"] as? String ?? "",
                ownerID: data["ownerID"] as? String ?? ""
            )
            loadMeals()
            loadOrders()
        }
    }
    
    private func loadMeals() {
        guard let rid = restaurant?.id else { return }
        db.collection("meals").whereField("restaurantID", isEqualTo: rid).getDocuments { snapshot, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            meals = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return Meal(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? "",
                    price: data["price"] as? Double ?? 0,
                    discountPrice: data["discountPrice"] as? Double ?? 0,
                    restaurantID: data["restaurantID"] as? String ?? "",
                    isAvailable: data["isAvailable"] as? Bool ?? true,
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            } ?? []
        }
    }
    
    private func loadOrders() {
        guard let rid = restaurant?.id else { return }
        db.collection("orders")
            .whereField("restaurantID", isEqualTo: rid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                        return
                    }
                    
                    self.orders = snapshot?.documents.compactMap { doc in
                        do {
                            return try doc.data(as: Order.self)
                        } catch {
                            print("Error decoding order: \(error)")
                            return nil
                        }
                    } ?? []
                    
                    self.isLoading = false
                }
            }
    }
    
    private func addMeal() {
        guard let rid = restaurant?.id else { return }
        guard let price = Double(newMealPrice), let discount = Double(newMealDiscountPrice) else {
            alertMessage = "Enter valid price numbers"
            showAlert = true
            return
        }
        let meal = [
            "name": newMealName,
            "description": newMealDescription,
            "price": price,
            "discountPrice": discount,
            "imageUrl": newMealImageUrl,
            "isAvailable": newMealAvailable,
            "restaurantID": rid,
            "createdAt": Timestamp(date: Date())
        ] as [String: Any]
        
        db.collection("meals").addDocument(data: meal) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                newMealName = ""; newMealDescription = ""; newMealPrice = ""; newMealDiscountPrice = ""; newMealImageUrl = ""; newMealAvailable = true
                loadMeals()
            }
        }
    }
    
    private func toggleMealAvailability(_ meal: Meal) {
        guard let id = meal.id else { return }
        db.collection("meals").document(id).updateData(["isAvailable": !meal.isAvailable]) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                loadMeals()
            }
        }
    }
    
    private func updateOrderStatus(_ order: Order, to newStatus: String) {
        guard let id = order.id else { return }
        db.collection("orders").document(id).updateData(["status": newStatus]) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                loadOrders()
            }
        }
    }
    
    private func updateRestaurantProfile() {
        guard let rid = restaurant?.id else { return }
        let data = ["name": editName, "location": editLocation, "imageUrl": editImageUrl]
        db.collection("restaurants").document(rid).updateData(data) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                loadRestaurantData()
            }
        }
    }
    
    private func groupOrdersByDate() -> [(Date, Double)] {
        let grouped = Dictionary(grouping: orders) { order in
            Calendar.current.startOfDay(for: order.createdAt)
        }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.totalAmount }) }
            .sorted { $0.0 < $1.0 }
    }
    private func logout() {
        do {
            try Auth.auth().signOut()
            authVM.userSession = nil
            authVM.isAuthenticated = false
            authVM.role = nil
        } catch {
            alertMessage = "Failed to log out: \(error.localizedDescription)"
            showAlert = true
        }
    }


}
