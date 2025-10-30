import SwiftUI
import FirebaseFirestore

struct CheckoutView: View {
    @State private var showMpesaField = false
    @State private var phoneNumber = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var paymentSuccess = false
    @State private var isAnimating = false
    
    @State private var navigateToOrders = false

    @EnvironmentObject var cartManager: CartManager

    private var totalAmount: Double {
        cartManager.totalAmount()
    }

    private var cartItems: [(String, Int, Double)] {
        cartManager.cartItems.map { item in
            (item.meal.name, item.quantity, item.meal.discountPrice * Double(item.quantity))
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            mainContent
            
            NavigationLink(destination: MyOrdersView(), isActive: $navigateToOrders) {
                    EmptyView()
                }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            alertView
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    // Background
    private var backgroundGradient: some View {
        Color.luxCream
            .ignoresSafeArea()
    }
    
    // Main Content
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                headerSection
                orderSummaryCard
                paymentSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                backButton
                
                Spacer()
                
                titleSection
                
                Spacer()
                
                progressIndicator
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
                .frame(maxWidth: 180)
        }
        .padding(.top, 16)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : -20)
    }
    
    private var backButton: some View {
        Button(action: {
            // Back action
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.luxBurgundy)
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .luxBurgundy.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("Secure Checkout")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
            
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.luxGold)
                    .font(.system(size: 11))
                Text("Encrypted Payment")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.luxBurgundy.opacity(0.2), lineWidth: 3)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.luxBurgundy, .luxGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                Text("3/4")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.luxBurgundy)
            }
            
            Text("Final Step")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    // Order Summary Card
    private var orderSummaryCard: some View {
        VStack(spacing: 24) {
            orderHeader
            itemsList
            totalSection
        }
        .padding(28)
        .background(cardBackground)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
        .animation(.easeOut(duration: 0.7).delay(0.2), value: isAnimating)
    }
    
    private var orderHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Order Summary")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                Text("Order #ORD-\(String(format: "%04d", Int.random(in: 1000...9999)))")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            statusBadge
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.luxGold, .luxGold.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 8)
            Text("Ready")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.luxBurgundy)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.luxGold.opacity(0.15))
        .cornerRadius(20)
    }
    
    private var itemsList: some View {
        VStack(spacing: 16) {
            ForEach(Array(cartItems.enumerated()), id: \.offset) { index, item in
                itemRow(item)
                
                if index != cartItems.count - 1 {
                    Divider()
                        .background(Color.luxBurgundy.opacity(0.1))
                }
            }
        }
    }
    
    private func itemRow(_ item: (String, Int, Double)) -> some View {
        HStack(spacing: 16) {
            itemImage
            itemDetails(item)
            Spacer()
            itemPrice(item.2)
        }
        .padding(.vertical, 4)
    }
    
    private var itemImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.luxBurgundy.opacity(0.1), .luxLightBurgundy.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "fork.knife")
                    .foregroundColor(.luxBurgundy)
                    .font(.system(size: 20))
            )
    }
    
    private func itemDetails(_ item: (String, Int, Double)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.0)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.luxDeepBurgundy)
            
            HStack(spacing: 8) {
                Text("Qty: \(item.1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.luxBurgundy)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.luxBurgundy.opacity(0.08))
                    .cornerRadius(6)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                    Text("Fresh")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.luxGold)
            }
        }
    }
    
    private func itemPrice(_ price: Double) -> some View {
        Text("KSh \(String(format: "%.2f", price))")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.luxDeepBurgundy)
    }
    
    private var totalSection: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.luxBurgundy.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            VStack(spacing: 10) {
                subtotalRow
                serviceFeeRow
                
                Rectangle()
                    .fill(Color.luxBurgundy.opacity(0.1))
                    .frame(height: 1)
                    .padding(.vertical, 4)
                
                totalRow
            }
        }
    }
    
    private var subtotalRow: some View {
        HStack {
            Text("Subtotal")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
            Text("KSh \(String(format: "%.2f", totalAmount))")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var serviceFeeRow: some View {
        HStack {
            HStack(spacing: 6) {
                Text("Service Fee")
                    .font(.system(size: 15))
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
            }
            .foregroundColor(.gray)
            
            Spacer()
            
            Text("Free")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.luxGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.luxGold.opacity(0.1))
                .cornerRadius(6)
        }
    }
    
    private var totalRow: some View {
        HStack {
            Text("Total Amount")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
            Spacer()
            Text("KSh \(String(format: "%.2f", totalAmount))")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.luxBurgundy)
        }
    }
    
    // Payment Section
    private var paymentSection: some View {
        VStack(spacing: 24) {
            paymentHeader
            mpesaButton
            
            if showMpesaField {
                phoneInputSection
            }
        }
        .padding(28)
        .background(cardBackground)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
        .animation(.easeOut(duration: 0.7).delay(0.3), value: isAnimating)
    }
    
    private var paymentHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Payment Method")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                Text("Choose your preferred option")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.luxGold)
                    .font(.system(size: 12))
                Text("Secure")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.luxBurgundy)
            }
        }
    }
    
    private var mpesaButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMpesaField.toggle()
            }
        }) {
            HStack(spacing: 16) {
                mpesaIcon
                mpesaText
                Spacer()
                chevronIcon
            }
            .padding(22)
            .background(mpesaButtonGradient)
            .cornerRadius(18)
            .shadow(color: .luxBurgundy.opacity(0.3), radius: 16, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.luxGold.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(showMpesaField ? 1.0 : 1.0)
        }
    }
    
    private var mpesaIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 48, height: 48)
            
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
            
            Image(systemName: "phone.fill")
                .font(.system(size: 20))
                .foregroundColor(.luxBurgundy)
        }
    }
    
    private var mpesaText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pay with M-Pesa")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.white)
            Text("Safe, fast & convenient payment")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: showMpesaField ? "chevron.up" : "chevron.down")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
            .rotationEffect(.degrees(showMpesaField ? 180 : 0))
    }
    
    private var mpesaButtonGradient: some View {
        LinearGradient(
            colors: [.luxBurgundy, .luxDeepBurgundy],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Phone Input Section
    private var phoneInputSection: some View {
        VStack(spacing: 20) {
            phoneInputHeader
            phoneInputRow
            confirmButton
            trustIndicators
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [.luxGold.opacity(0.3), .luxBurgundy.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .luxBurgundy.opacity(0.12), radius: 16, x: 0, y: 8)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }
    
    private var phoneInputHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter M-Pesa Number")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
            
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.luxGold)
                Text("You'll receive a payment prompt on your phone")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var phoneInputRow: some View {
        HStack(spacing: 14) {
            countryCodeSection
            phoneNumberField
        }
    }
    
    private var countryCodeSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Text("🇰🇪")
                    .font(.system(size: 20))
                Text("+254")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.luxDeepBurgundy)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.08), .luxLightBurgundy.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.luxBurgundy.opacity(0.15), lineWidth: 1)
            )
            
            Text("Kenya")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var phoneNumberField: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("7XX XXX XXX", text: $phoneNumber)
                .keyboardType(.numberPad)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.luxDeepBurgundy)
                .padding(18)
                .background(Color.luxCream)
                .cornerRadius(14)
                .overlay(phoneFieldBorder)
                .onChange(of: phoneNumber) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count <= 9 {
                        phoneNumber = filtered
                    }
                }
            
            phoneValidationRow
        }
    }
    
    private var phoneFieldBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                phoneNumber.count == 9 ?
                LinearGradient(
                    colors: [.luxGold, .luxBurgundy],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [.gray.opacity(0.2), .gray.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: phoneNumber.count == 9 ? 2 : 1
            )
    }
    
    private var phoneValidationRow: some View {
        HStack {
            if phoneNumber.count == 9 {
                validNumberIndicator
            } else if !phoneNumber.isEmpty {
                invalidNumberIndicator
            }
            
            Spacer()
            
            Text("\(phoneNumber.count)/9")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 6)
    }
    
    private var validNumberIndicator: some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.luxGold)
                .font(.system(size: 13))
            Text("Valid number")
                .foregroundColor(.luxBurgundy)
                .font(.system(size: 12, weight: .medium))
        }
    }
    
    private var invalidNumberIndicator: some View {
        HStack(spacing: 5) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 13))
            Text("Enter 9 digits")
                .foregroundColor(.orange)
                .font(.system(size: 12, weight: .medium))
        }
    }
    
    private var confirmButton: some View {
        Button(action: handlePayment) {
            HStack(spacing: 14) {
                if isProcessing {
                    processingContent
                } else {
                    confirmContent
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(confirmButtonGradient)
            .cornerRadius(16)
            .shadow(
                color: phoneNumber.count == 9 && !isProcessing ? .luxBurgundy.opacity(0.4) : .clear,
                radius: 16,
                x: 0,
                y: 8
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        phoneNumber.count == 9 && !isProcessing ?
                        Color.luxGold.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isProcessing ? 0.98 : 1.0)
        }
        .disabled(phoneNumber.count != 9 || isProcessing)
        .animation(.easeInOut(duration: 0.2), value: phoneNumber.count)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
    
    private var processingContent: some View {
        Group {
            ProgressView()
                .scaleEffect(0.9)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Processing Payment...")
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundColor(.white)
        }
    }
    
    private var confirmContent: some View {
        Group {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            VStack(spacing: 3) {
                Text("Confirm Payment")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                Text("KSh \(String(format: "%.2f", totalAmount))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
    
    private var confirmButtonGradient: some View {
        LinearGradient(
            colors: phoneNumber.count == 9 && !isProcessing ?
            [.luxBurgundy, .luxDeepBurgundy] :
            [.gray.opacity(0.5), .gray.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var trustIndicators: some View {
        HStack(spacing: 0) {
            trustIndicator(icon: "shield.lefthalf.filled", text: "Bank-level security")
            
            Spacer()
            
            trustIndicator(icon: "bolt.fill", text: "Instant")
            
            Spacer()
            
            trustIndicator(icon: "creditcard", text: "No fees")
        }
        .padding(.top, 12)
    }
    
    private func trustIndicator(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(.luxGold)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    // Shared Components
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white)
            .shadow(color: .luxBurgundy.opacity(0.12), radius: 24, x: 0, y: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.15), .luxGold.opacity(0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var alertView: Alert {
        Alert(
            title: Text(paymentSuccess ? "Payment Initiated!" : "Invalid Input"),
            message: Text(alertMessage),
            dismissButton: .default(Text("Got it!"))
        )
    }
    
    // Actions
    private func handlePayment() {
        let validPrefixes = ["7", "1"]
        guard phoneNumber.count == 9, validPrefixes.contains(String(phoneNumber.prefix(1))) else {
            alertMessage = "Please enter a valid M-Pesa number (07XXXXXXXX or 01XXXXXXXX)."
            showAlert = true
            return
        }

        
        isProcessing = true
        let url = URL(string: "http://localhost:3000/stkpush")!  // Use ngrok URL on device
        let body: [String: Any] = [
            "phoneNumber": phoneNumber,
            "amount": totalAmount
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let data = data,
                      let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = response["success"] as? Bool else {
                    alertMessage = "Invalid response."
                    showAlert = true
                    return
                }
                
                if success {
                    alertMessage = "Payment prompt sent to +254\(phoneNumber)"
                    paymentSuccess = true
                    
                    let db = Firestore.firestore()
                        let orderData: [String: Any] = [
                            "userID": "currentUserID", // replace with actual user ID
                            "amountPaid": totalAmount,
                            "paymentMethod": "MPesa",
                            "status": "pending",
                            "createdAt": Timestamp(),
                            "cartItems": cartManager.cartItems.map { [
                                "mealID": $0.meal.id ?? "",
                                "mealName": $0.meal.name,
                                "quantity": $0.quantity,
                                "price": $0.meal.discountPrice
                            ]}
                        ]

                        db.collection("orders").addDocument(data: orderData) { err in
                            if let err = err {
                                print("Error adding order: \(err.localizedDescription)")
                            } else {
                                print("Order successfully added!")
                            }
                        }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToOrders = true
                        }
                } else {
                    alertMessage = "Failed to initiate payment."
                    paymentSuccess = false
                }
                showAlert = true
            }
        }.resume()
    }
}
