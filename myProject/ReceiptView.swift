import SwiftUI
import FirebaseFirestore

struct ReceiptView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.luxCream.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                receiptContent
                actionButtons
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.luxBurgundy)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .luxBurgundy.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                Spacer()
                
                Text("Order Receipt")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Spacer()
                
                // Empty view for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.luxBurgundy, .luxBurgundy.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 200)
        }
    }
    
    // MARK: - Receipt Content (Simplified)
    private var receiptContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                receiptCard
            }
            .padding(.vertical, 24)
        }
    }
    
    private var receiptCard: some View {
        VStack(spacing: 0) {
            receiptHeader
            itemsList
            totalSection
            receiptFooter
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .luxBurgundy.opacity(0.12), radius: 24, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    private var receiptHeader: some View {
        VStack(spacing: 12) {
            Text("ORDER CONFIRMED")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.luxBurgundy)
                .tracking(1)
            
            Text(order.orderNumber)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            
            Text(order.createdAt.formatted(date: .complete, time: .shortened))
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(Color.luxBurgundy.opacity(0.05))
    }
    
    private var itemsList: some View {
        VStack(spacing: 16) {
            ForEach(order.items, id: \.id) { item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.mealName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.luxDeepBurgundy)
                        
                        Text("Qty: \(item.quantity) × KSh \(String(format: "%.2f", item.price))")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("KSh \(String(format: "%.2f", item.price * Double(item.quantity)))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.luxBurgundy)
                }
                
                if item.id != order.items.last?.id {
                    Divider()
                        .background(Color.luxBurgundy.opacity(0.1))
                }
            }
        }
        .padding(24)
    }
    
    private var totalSection: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.luxBurgundy.opacity(0.2))
            
            HStack {
                Text("Total Amount")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.luxDeepBurgundy)
                
                Spacer()
                
                Text("KSh \(String(format: "%.2f", order.totalAmount))")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.luxBurgundy)
            }
            
            HStack {
                Text("Payment Method")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: paymentIcon(for: order.paymentMethod))
                        .font(.system(size: 12))
                        .foregroundColor(.luxBurgundy)
                    Text(order.paymentMethod)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.luxDeepBurgundy)
                }
            }
            
            HStack {
                Text("Status")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                ReceiptStatusBadge(status: order.status)
            }
        }
        .padding(24)
        .background(Color.luxCream)
    }
    
    private var receiptFooter: some View {
        VStack(spacing: 8) {
            Text("Thank you for your order!")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(.luxBurgundy)
            
            Text("We'll notify you when your order is ready for pickup")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Color.white)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: shareReceipt) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                    Text("Share Receipt")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.luxBurgundy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.luxBurgundy.opacity(0.3), lineWidth: 1)
                )
            }
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.luxBurgundy, .luxDeepBurgundy],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
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
    
    private func shareReceipt() {
        // You can implement sharing functionality here
        // This would typically use UIActivityViewController
        print("Share receipt functionality would go here")
    }
}

// MARK: - Receipt Status Badge (Separate component)
struct ReceiptStatusBadge: View {
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
