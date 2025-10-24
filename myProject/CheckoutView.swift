import SwiftUI

struct CheckoutView: View {
    @State private var showMpesaField = false
    @State private var phoneNumber = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var paymentSuccess = false
    
    var totalAmount: Double = 300.0
    let cartItems = [
        ("Gourmet Burger", 1, 300.0)
    ]
    
    var body: some View {
        ZStack {
            backgroundGradient
            mainContent
        }
        .alert(isPresented: $showAlert) {
            alertView
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.green.opacity(0.1),
                Color.mint.opacity(0.05),
                Color.white,
                Color.green.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                orderSummaryCard
                paymentSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                backButton
                Spacer()
                titleSection
                Spacer()
                progressIndicator
            }
            
            dividerLine
        }
        .padding(.top, 10)
    }
    
    private var backButton: some View {
        Button(action: {
            // Back action
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.green)
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 4) {
            Text("Secure Checkout")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            HStack(spacing: 4) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("256-bit SSL Encrypted")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("3/4")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
            }
            Text("Almost done!")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var dividerLine: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.green.opacity(0.3))
            .padding(.horizontal, 40)
    }
    
    // MARK: - Order Summary Card
    private var orderSummaryCard: some View {
        VStack(spacing: 20) {
            orderHeader
            itemsList
            totalSection
        }
        .padding(24)
        .background(cardBackground)
    }
    
    private var orderHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order Summary")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Text("Order #ORD-2024-001")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            statusBadge
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Ready to Pay")
                .font(.caption.bold())
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var itemsList: some View {
        VStack(spacing: 12) {
            ForEach(cartItems, id: \.0) { item in
                itemRow(item)
                
                if item.0 != cartItems.last?.0 {
                    Divider()
                        .opacity(0.5)
                }
            }
        }
    }
    
    private func itemRow(_ item: (String, Int, Double)) -> some View {
        HStack(spacing: 12) {
            itemImage
            itemDetails(item)
            Spacer()
            itemPrice(item.2)
        }
        .padding(.vertical, 8)
    }
    
    private var itemImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.green.opacity(0.1))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: "fork.knife")
                    .foregroundColor(.green)
                    .font(.title3)
            )
    }
    
    private func itemDetails(_ item: (String, Int, Double)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.0)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                Text("Qty: \(item.1)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                
                Text("Fresh & Hot")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
    
    private func itemPrice(_ price: Double) -> some View {
        Text("KSh \(String(format: "%.2f", price))")
            .font(.headline.bold())
            .foregroundColor(.primary)
    }
    
    private var totalSection: some View {
        VStack(spacing: 12) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.green.opacity(0.3))
            
            VStack(spacing: 8) {
                subtotalRow
                serviceFeeRow
                totalRow
            }
        }
    }
    
    private var subtotalRow: some View {
        HStack {
            Text("Subtotal")
                .foregroundColor(.secondary)
            Spacer()
            Text("KSh \(String(format: "%.2f", totalAmount))")
                .foregroundColor(.secondary)
        }
    }
    
    private var serviceFeeRow: some View {
        HStack {
            Text("Service Fee")
                .foregroundColor(.secondary)
            Spacer()
            Text("Free")
                .foregroundColor(.green)
                .font(.caption.bold())
        }
    }
    
    private var totalRow: some View {
        HStack {
            Text("Total Amount")
                .font(.title3.bold())
                .foregroundColor(.primary)
            Spacer()
            Text("KSh \(String(format: "%.2f", totalAmount))")
                .font(.title2.bold())
                .foregroundColor(.green)
        }
    }
    
    // MARK: - Payment Section
    private var paymentSection: some View {
        VStack(spacing: 20) {
            paymentHeader
            mpesaButton
            
            if showMpesaField {
                phoneInputSection
            }
        }
        .padding(24)
        .background(cardBackground)
    }
    
    private var paymentHeader: some View {
        HStack {
            Text("Payment Method")
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("Secure")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
        }
    }
    
    private var mpesaButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showMpesaField.toggle()
            }
        }) {
            HStack(spacing: 12) {
                mpesaIcon
                mpesaText
                Spacer()
                chevronIcon
            }
            .padding(20)
            .background(mpesaButtonGradient)
            .cornerRadius(16)
            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
            .scaleEffect(showMpesaField ? 1.02 : 1.0)
        }
    }
    
    private var mpesaIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
            
            Image(systemName: "phone.fill")
                .font(.title3)
                .foregroundColor(.green)
        }
    }
    
    private var mpesaText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Pay with M-Pesa")
                .font(.headline.bold())
                .foregroundColor(.white)
            Text("Safe, fast & convenient")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: showMpesaField ? "chevron.up" : "chevron.down")
            .font(.title3)
            .foregroundColor(.white)
            .rotationEffect(.degrees(showMpesaField ? 180 : 0))
    }
    
    private var mpesaButtonGradient: some View {
        LinearGradient(
            colors: [Color.green, Color.green.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Phone Input Section
    private var phoneInputSection: some View {
        VStack(spacing: 16) {
            phoneInputHeader
            phoneInputRow
            confirmButton
            trustIndicators
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .green.opacity(0.1), radius: 12, x: 0, y: 4)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    private var phoneInputHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter your M-Pesa number")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("You'll receive a payment prompt on your phone")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var phoneInputRow: some View {
        HStack(spacing: 12) {
            countryCodeSection
            phoneNumberField
        }
    }
    
    private var countryCodeSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("🇰🇪")
                Text("+254")
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            Text("Kenya")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var phoneNumberField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("7XX XXX XXX", text: $phoneNumber)
                .keyboardType(.numberPad)
                .font(.headline)
                .padding(16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
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
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                phoneNumber.count == 9 ? Color.green : Color.gray.opacity(0.3),
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
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 4)
    }
    
    private var validNumberIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text("Valid number")
                .foregroundColor(.green)
        }
    }
    
    private var invalidNumberIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
            Text("Enter 9 digits")
                .foregroundColor(.orange)
        }
    }
    
    private var confirmButton: some View {
        Button(action: handlePayment) {
            HStack(spacing: 12) {
                if isProcessing {
                    processingContent
                } else {
                    confirmContent
                }
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(confirmButtonGradient)
            .cornerRadius(16)
            .shadow(
                color: phoneNumber.count == 9 ? .green.opacity(0.4) : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(isProcessing ? 0.98 : 1.0)
        }
        .disabled(phoneNumber.count != 9 || isProcessing)
        .animation(.easeInOut(duration: 0.2), value: phoneNumber.count)
    }
    
    private var processingContent: some View {
        Group {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Processing...")
                .font(.headline.bold())
                .foregroundColor(.white)
        }
    }
    
    private var confirmContent: some View {
        Group {
            Image(systemName: "lock.shield.fill")
                .font(.title3)
                .foregroundColor(.white)
            
            VStack(spacing: 2) {
                Text("Confirm Payment")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text("KSh \(String(format: "%.2f", totalAmount))")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
    
    private var confirmButtonGradient: some View {
        LinearGradient(
            colors: phoneNumber.count == 9 && !isProcessing ?
                [Color.green, Color.green.opacity(0.8)] :
                [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var trustIndicators: some View {
        HStack(spacing: 20) {
            trustIndicator(icon: "shield.checkered", text: "Bank-level security")
            trustIndicator(icon: "clock", text: "Instant processing")
            trustIndicator(icon: "hand.raised.fill", text: "No hidden fees")
        }
        .padding(.top, 8)
    }
    
    private func trustIndicator(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption)
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Shared Components
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .green.opacity(0.1), radius: 20, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var alertView: Alert {
        Alert(
            title: Text(paymentSuccess ? "Payment Initiated!" : "Invalid Input"),
            message: Text(alertMessage),
            dismissButton: .default(Text("Got it!"))
        )
    }
    
    // MARK: - Actions
    private func handlePayment() {
        withAnimation(.spring()) {
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            if phoneNumber.count == 9 {
                alertMessage = "M-Pesa payment prompt sent to +254\(phoneNumber)\n\nPlease check your phone and enter your M-Pesa PIN to complete the payment."
                paymentSuccess = true
            } else {
                alertMessage = "Please enter a valid 9-digit phone number."
                paymentSuccess = false
            }
            showAlert = true
        }
    }
}
