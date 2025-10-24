import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var navigateToCheckout = false
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: Meal?
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .alert("Remove Item", isPresented: $showDeleteConfirmation) {
            deleteConfirmationAlert
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.green.opacity(0.08),
                Color.mint.opacity(0.04),
                Color(.systemGroupedBackground),
                Color.green.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerSection
            
            if cartManager.cartItems.isEmpty {
                emptyCartView
            } else {
                cartContentView
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Cart")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    if !cartManager.cartItems.isEmpty {
                        Text("\(cartManager.cartItems.count) item\(cartManager.cartItems.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !cartManager.cartItems.isEmpty {
                    cartSummaryBadge
                }
            }
            
            // Elegant underline
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120, height: 3)
                    .cornerRadius(2)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
    
    private var cartSummaryBadge: some View {
        VStack(spacing: 2) {
            Text("Total")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("KSh \(Int(cartManager.totalAmount()))")
                .font(.headline.bold())
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "cart")
                    .font(.system(size: 50))
                    .foregroundColor(.green.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Your cart is empty")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Add some delicious items to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Cart Content View
    private var cartContentView: some View {
        VStack(spacing: 0) {
            cartItemsList
            checkoutSection
        }
    }
    
    // MARK: - Cart Items List
    private var cartItemsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(cartManager.cartItems) { item in
                    cartItemCard(item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func cartItemCard(_ item: CartItem) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                itemImage(item.meal)
                itemDetails(item)
                Spacer()
                quantityControls(item)
                deleteButton(item.meal)
            }
            
            itemTotalRow(item)
        }
        .padding(20)
        .background(cardBackground)
    }
    
    private func itemImage(_ meal: Meal) -> some View {
        AsyncImage(url: URL(string: meal.imageUrl)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color.green.opacity(0.1)
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundColor(.green.opacity(0.6))
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func itemDetails(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.meal.name)
                .font(.headline.bold())
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("KSh \(Int(item.meal.discountPrice))")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                
                Text("each")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Quality indicator
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text("Fresh")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.1))
            .cornerRadius(4)
        }
    }
    
    private func quantityControls(_ item: CartItem) -> some View {
        HStack(spacing: 0) {
            quantityButton("-") {
                withAnimation(.spring(response: 0.3)) {
                    cartManager.decreaseQuantity(for: item.meal)
                }
            }
            
            Text("\(item.quantity)")
                .font(.headline.bold())
                .foregroundColor(.primary)
                .frame(width: 40)
                .padding(.vertical, 8)
                .background(Color.white)
            
            quantityButton("+") {
                withAnimation(.spring(response: 0.3)) {
                    cartManager.increaseQuantity(for: item.meal)
                }
            }
        }
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .shadow(color: .green.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func quantityButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.title3.bold())
                .foregroundColor(.green)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func deleteButton(_ meal: Meal) -> some View {
        Button(action: {
            itemToDelete = meal
            showDeleteConfirmation = true
        }) {
            Image(systemName: "trash.fill")
                .font(.title3)
                .foregroundColor(.red.opacity(0.8))
                .padding(8)
                .background(Color.red.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func itemTotalRow(_ item: CartItem) -> some View {
        HStack {
            Text("Item Total:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("KSh \(Int(item.meal.discountPrice * Double(item.quantity)))")
                .font(.headline.bold())
                .foregroundColor(.green)
        }
        .padding(.top, 8)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.green.opacity(0.2)),
            alignment: .top
        )
    }
    
    // MARK: - Checkout Section
    private var checkoutSection: some View {
        VStack(spacing: 20) {
            orderSummary
            checkoutButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -8)
        )
    }
    
    private var orderSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Order Summary")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Secure")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 8) {
                summaryRow("Subtotal:", "KSh \(Int(cartManager.totalAmount()))", .secondary)
                summaryRow("Delivery:", "Standard", .green, isDeliveryInfo: true)
                
                Divider()
                    .background(Color.green.opacity(0.3))
                
                summaryRow("Total:", "KSh \(Int(cartManager.totalAmount()))", .primary, isBold: true)
            }
        }
        .padding(20)
        .background(Color.green.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func summaryRow(_ label: String, _ value: String, _ color: Color, isBold: Bool = false, isDeliveryInfo: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isBold ? .headline.bold() : .body)
                .foregroundColor(isBold ? .primary : .secondary)
            
            Spacer()
            
            if isDeliveryInfo {
                Text(value)
                    .font(.caption.bold())
                    .foregroundColor(color)
            } else {
                Text(value)
                    .font(isBold ? .title3.bold() : .body)
                    .foregroundColor(color)
            }
        }
    }
    
    private var checkoutButton: some View {
        Button(action: {
            navigateToCheckout = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                
                VStack(spacing: 2) {
                    Text("Proceed to Checkout")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Secure Payment")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .green.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .navigationDestination(isPresented: $navigateToCheckout) {
            CheckoutView()
                .environmentObject(cartManager)
        }
    }
    
    // MARK: - Shared Components
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .green.opacity(0.1), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green.opacity(0.15), lineWidth: 1)
            )
    }
    
    private var deleteConfirmationAlert: some View {
        Group {
            Button("Remove", role: .destructive) {
                if let meal = itemToDelete {
                    withAnimation(.spring()) {
                        cartManager.removeFromCart(meal)
                    }
                }
                itemToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
        }
    }
}
