import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Color Palette

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var navigateToCheckout = false
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: Meal?
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isAnimating = true
                }
            }
        }
        .alert("Remove Item", isPresented: $showDeleteConfirmation) {
            deleteConfirmationAlert
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.luxCream, Color.white, .luxCream],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
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
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Cart")
                        .font(.system(size: 36, weight: .light, design: .serif))
                        .foregroundColor(.luxDeepBurgundy)
                    
                    if !cartManager.cartItems.isEmpty {
                        Text("\(cartManager.cartItems.count) item\(cartManager.cartItems.count == 1 ? "" : "s")")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(x: isAnimating ? 0 : -20)
                
                Spacer()
                
                if !cartManager.cartItems.isEmpty {
                    cartSummaryBadge
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : 20)
                }
            }
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.luxBurgundy, .luxGold.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100, height: 3)
                .cornerRadius(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isAnimating ? 1 : 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private var cartSummaryBadge: some View {
        VStack(spacing: 4) {
            Text("TOTAL")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundColor(.luxBurgundy.opacity(0.7))
            Text("KSh \(Int(cartManager.totalAmount()))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.luxBurgundy)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .luxBurgundy.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.luxBurgundy.opacity(0.08))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.1), .luxGold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bag")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.luxBurgundy.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Your cart is empty")
                    .font(.system(size: 24, weight: .light, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Text("Discover delicious meals waiting for you")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            cartItemsList
            checkoutSection
        }
    }
    
    private var cartItemsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(Array(cartManager.cartItems.enumerated()), id: \.element.id) { index, item in
                    cartItemCard(item)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: isAnimating)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
    
    private func cartItemCard(_ item: CartItem) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                itemImage(item.meal)
                itemDetails(item)
                Spacer()
                VStack(spacing: 12) {
                    quantityControls(item)
                    deleteButton(item.meal)
                }
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
                Color.luxBurgundy.opacity(0.08)
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundColor(.luxBurgundy.opacity(0.5))
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func itemDetails(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.meal.name)
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("KSh \(Int(item.meal.discountPrice))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.luxBurgundy)
                
                Text("each")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 9))
                    .foregroundColor(.luxBurgundy)
                Text("FRESH")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.luxBurgundy)
                    .tracking(0.5)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.luxBurgundy.opacity(0.1))
            .cornerRadius(6)
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
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.luxDeepBurgundy)
                .frame(width: 36)
                .padding(.vertical, 6)
                .background(Color.white)
            
            quantityButton("+") {
                withAnimation(.spring(response: 0.3)) {
                    cartManager.increaseQuantity(for: item.meal)
                }
            }
        }
        .background(Color.luxBurgundy.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.luxBurgundy.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func quantityButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.luxBurgundy)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func deleteButton(_ meal: Meal) -> some View {
        Button(action: {
            itemToDelete = meal
            showDeleteConfirmation = true
        }) {
            Image(systemName: "trash")
                .font(.system(size: 16))
                .foregroundColor(.luxDeepBurgundy.opacity(0.6))
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.luxDeepBurgundy.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func itemTotalRow(_ item: CartItem) -> some View {
        HStack {
            Text("Item Total")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("KSh \(Int(item.meal.discountPrice * Double(item.quantity)))")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.luxBurgundy)
        }
        .padding(.top, 12)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.luxBurgundy.opacity(0.15)),
            alignment: .top
        )
    }
    
    private var checkoutSection: some View {
        VStack(spacing: 20) {
            orderSummary
            checkoutButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .luxBurgundy.opacity(0.1), radius: 20, x: 0, y: -8)
        )
    }
    
    private var orderSummary: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Summary")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.luxBurgundy)
                    Text("SECURE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(.luxBurgundy)
                }
            }
            
            VStack(spacing: 10) {
                summaryRow("Subtotal", "KSh \(Int(cartManager.totalAmount()))", .secondary)
                summaryRow("Delivery", "Standard", .luxBurgundy, isSpecial: true)
                
                Divider()
                    .background(Color.luxBurgundy.opacity(0.2))
                
                summaryRow("Total", "KSh \(Int(cartManager.totalAmount()))", .luxDeepBurgundy, isBold: true)
            }
        }
        .padding(20)
        .background(Color.luxCream.opacity(0.4))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.luxBurgundy.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func summaryRow(_ label: String, _ value: String, _ color: Color, isBold: Bool = false, isSpecial: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: isBold ? 17 : 15, weight: isBold ? .semibold : .regular))
                .foregroundColor(isBold ? .luxDeepBurgundy : .gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isSpecial ? 12 : (isBold ? 19 : 15), weight: isBold ? .bold : .medium))
                .foregroundColor(color)
        }
    }
    
    private var checkoutButton: some View {
        Button(action: {
            navigateToCheckout = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                VStack(spacing: 2) {
                    Text("Proceed to Checkout")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Secure Payment")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.luxBurgundy, .luxDeepBurgundy],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .luxBurgundy.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .navigationDestination(isPresented: $navigateToCheckout) {
            CheckoutView()
                .environmentObject(cartManager)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .luxBurgundy.opacity(0.08), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
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
