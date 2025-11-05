import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct MyOrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isAnimating = false
    @State private var selectedStatusFilter = "All"
    private let statusFilters = ["All", "pending", "ready", "delivered"]

    private var filteredOrders: [Order] {
        if selectedStatusFilter == "All" {
            return orders
        } else {
            return orders.filter { $0.status.lowercased() == selectedStatusFilter.lowercased() }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxCream.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(message: errorMessage)
                } else if filteredOrders.isEmpty {
                    emptyStateView
                } else {
                    ordersListView
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .top) {
                customNavigationBar
            }
            .onAppear {
                fetchOrders()
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("My Orders")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundColor(.luxDeepBurgundy)
                    
                    if !filteredOrders.isEmpty {
                        Text("\(filteredOrders.count) order\(filteredOrders.count == 1 ? "" : "s")")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(x: isAnimating ? 0 : -20)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Status Filter Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(statusFilters, id: \.self) { status in
                        Button(action: {
                            selectedStatusFilter = status
                        }) {
                            Text(status.capitalized)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedStatusFilter == status ? .white : .luxBurgundy)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedStatusFilter == status ?
                                    Color.luxBurgundy : Color.luxBurgundy.opacity(0.1)
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.luxBurgundy.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.luxBurgundy, .luxBurgundy.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(width: 140)
                .padding(.leading, 24)
                .opacity(isAnimating ? 1 : 0)
        }
        .background(Color.luxCream)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.luxBurgundy.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.luxBurgundy, .luxGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
            }
            
            Text("Loading your orders...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.luxDeepBurgundy)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.luxLightBurgundy.opacity(0.15), .luxBurgundy.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.luxBurgundy)
            }
            
            VStack(spacing: 8) {
                Text("Oops!")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.top, 100)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.08), .luxGold.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "cart.badge.questionmark")
                    .font(.system(size: 60))
                    .foregroundColor(.luxBurgundy.opacity(0.6))
            }
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimating)
            
            VStack(spacing: 10) {
                Text("No Orders Yet")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Text("Start exploring and place your first order")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
            
            NavigationLink(destination: HomeView()) {
                HStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 16))
                    Text("Browse Restaurants")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.luxBurgundy, .luxDeepBurgundy],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: .luxBurgundy.opacity(0.3), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.luxGold.opacity(0.3), lineWidth: 1)
                )
            }
            
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
        }
        .padding(.top, 100)
    }
    
    // MARK: - Orders List View
    private var ordersListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { index, order in
                    OrderCard(order: order)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: isAnimating)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 120)
            .padding(.bottom, 40)
        }
    }

    private func fetchOrders() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to view your orders."
            isLoading = false
            return
        }
        
        print("🔍 Fetching orders for user: \(userID)")
        
        let db = Firestore.firestore()
        db.collection("orders")
            .whereField("customerID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Error fetching orders: \(error.localizedDescription)"
                        self.isLoading = false
                        print("Error fetching orders: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        self.orders = []
                        self.isLoading = false
                        print("No orders found for user: \(userID)")
                        return
                    }
                    
                    print("Found \(snapshot.documents.count) documents")
                    
                    // Debug: Print raw document data
                    for document in snapshot.documents {
                        print("   Order document: \(document.documentID)")
                        print("   Data: \(document.data())")
                    }
                    
                    self.orders = snapshot.documents.compactMap { doc in
                        do {
                            let order = try doc.data(as: Order.self)
                            print("Successfully decoded order: \(order.orderNumber)")
                            return order
                        } catch {
                            print("Error decoding order \(doc.documentID): \(error)")
                            print("   Raw data: \(doc.data())")
                            return nil
                        }
                    }
                    
                    print("Final orders count: \(self.orders.count)")
                    self.isLoading = false
                }
            }
    }

    // MARK: - Updated Order Card with Receipt
    struct OrderCard: View {
        let order: Order
        @State private var showReceipt = false
        
        var body: some View {
            VStack(spacing: 0) {
                // Header Section
                HStack(alignment: .top, spacing: 16) {
                    orderIcon
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order #\(order.orderNumber)")
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundColor(.luxDeepBurgundy)
                        
                        // Show first item name + count of additional items
                        if let firstItem = order.items.first {
                            Text("\(firstItem.mealName)\(order.items.count > 1 ? " + \(order.items.count - 1) more" : "")")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text(order.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 13))
                            }
                            
                            Circle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 3, height: 3)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(order.createdAt.formatted(date: .omitted, time: .shortened))
                                    .font(.system(size: 13))
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: order.status)
                }
                .padding(20)
                
                Divider()
                    .background(Color.luxBurgundy.opacity(0.1))
                    .padding(.horizontal, 20)
                
                // Details Section
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Payment Method")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 6) {
                            Image(systemName: paymentIcon(for: order.paymentMethod))
                                .font(.system(size: 14))
                                .foregroundColor(.luxBurgundy)
                            Text(order.paymentMethod)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.luxDeepBurgundy)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Total Amount")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("KSh \(String(format: "%.2f", order.totalAmount))")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(.luxBurgundy)
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [.luxCream, .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Receipt Button Section
                HStack {
                    Button(action: {
                        showReceipt = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.luxBurgundy)
                            
                            Text("View Receipt")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.luxBurgundy)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.luxBurgundy.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.luxBurgundy.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Quick status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor(for: order.status))
                            .frame(width: 8, height: 8)
                        
                        Text(order.status.capitalized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .luxBurgundy.opacity(0.12), radius: 16, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.15), .luxGold.opacity(0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .sheet(isPresented: $showReceipt) {
                ReceiptView(order: order)
            }
        }
        
        private var orderIcon: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.1), .luxLightBurgundy.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 24))
                    .foregroundColor(.luxBurgundy)
            }
        }
        
        private func paymentIcon(for method: String) -> String {
            switch method.lowercased() {
            case "m-pesa", "mpesa":
                return "phone.fill"
            case "card", "credit card":
                return "creditcard.fill"
            case "cash":
                return "banknote.fill"
            default:
                return "dollarsign.circle.fill"
            }
        }
        
        private func statusColor(for status: String) -> Color {
            switch status.lowercased() {
            case "pending":
                return .orange
            case "preparing":
                return .luxGold
            case "ready":
                return .green
            case "delivered":
                return .luxBurgundy
            case "completed":
                return .luxDeepBurgundy
            default:
                return .gray
            }
        }
    }
    // MARK: - Status Badge
    struct StatusBadge: View {
        let status: String
        
        var badgeColors: (background: Color, text: Color) {
            switch status.lowercased() {
            case "pending":
                return (.orange.opacity(0.15), .orange)
            case "preparing":
                return (.luxGold.opacity(0.15), .luxGold.opacity(0.8))
            case "ready":
                return (.green.opacity(0.15), .green)
            case "delivered":
                return (.luxBurgundy.opacity(0.15), .luxBurgundy)
            case "completed":
                return (.luxGold.opacity(0.2), .luxDeepBurgundy)
            default:
                return (.gray.opacity(0.15), .gray)
            }
        }
        
        var statusIcon: String {
            switch status.lowercased() {
            case "pending":
                return "clock.fill"
            case "preparing":
                return "flame.fill"
            case "ready":
                return "checkmark.circle.fill"
            case "delivered":
                return "checkmark.seal.fill"
            case "completed":
                return "star.fill"
            default:
                return "questionmark.circle.fill"
            }
        }
        
        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .font(.system(size: 11))
                    .foregroundColor(badgeColors.text)
                
                Text(status.capitalized)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(badgeColors.text)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(badgeColors.background)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(badgeColors.text.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
