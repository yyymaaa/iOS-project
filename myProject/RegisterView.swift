// MARK: - Register View
import SwiftUI
import Firebase


struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var restaurantName = ""
    @State private var restaurantLocation = ""
    @State private var selectedRole = "User"
    @State private var passwordError = ""
    @State private var showPasswordError = false
    @State private var isAnimating = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let roles = ["User", "Restaurant"]
    
    private let burgundy = Color(red: 0.5, green: 0.13, blue: 0.13)
    private let deepBurgundy = Color(red: 0.35, green: 0.09, blue: 0.09)
    private let cream = Color(red: 0.98, green: 0.97, blue: 0.95)
    private let gold = Color(red: 0.85, green: 0.65, blue: 0.13)
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [cream, Color.white, cream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(gold.opacity(0.06))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: 160, y: -300)
            
            Circle()
                .fill(burgundy.opacity(0.05))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -180, y: 400)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(burgundy)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [gold.opacity(0.8), gold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: gold.opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)
                        
                        Text("Create Account")
                            .font(.system(size: 34, weight: .light, design: .serif))
                            .foregroundColor(deepBurgundy)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                        
                        Text("Join our exclusive culinary network")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                    }
                    .padding(.bottom, 40)
                    
                    // Main Form Card
                    VStack(spacing: 26) {
                        // Role Selector
                        HStack(spacing: 0) {
                            ForEach(roles, id: \.self) { role in
                                Button(action: { withAnimation(.spring(response: 0.3)) { selectedRole = role } }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: role == "User" ? "person.fill" : "building.2.fill")
                                            .font(.system(size: 22))
                                        Text(role)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(selectedRole == role ? .white : burgundy)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        selectedRole == role ?
                                        LinearGradient(colors: [burgundy, deepBurgundy], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(14)
                                }
                            }
                        }
                        .padding(6)
                        .background(cream.opacity(0.6))
                        .cornerRadius(16)
                        
                        Divider()
                            .background(burgundy.opacity(0.2))
                            .padding(.vertical, 4)
                        
                        // Dynamic Fields
                        if selectedRole == "User" {
                            luxuryTextField(icon: "person", placeholder: "Full Name", text: $fullName)
                        } else {
                            luxuryTextField(icon: "building.2", placeholder: "Restaurant Name", text: $restaurantName)
                            luxuryTextField(icon: "location", placeholder: "Location", text: $restaurantLocation)
                        }
                        
                        luxuryTextField(icon: "envelope", placeholder: "Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        luxuryTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                        luxuryTextField(icon: "lock.shield", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        
                        if showPasswordError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(passwordError)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.leading)
                            }
                            .foregroundColor(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        Button(action: register) {
                            HStack(spacing: 12) {
                                Text("Create Account")
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: gold.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .padding(.top, 12)
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PASSWORD REQUIREMENTS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(burgundy.opacity(0.6))
                                .tracking(1)
                            
                            requirementRow(text: "At least 8 characters", met: password.count >= 8)
                            requirementRow(text: "Upper & lowercase letters", met: password.contains(where: { $0.isUppercase }) && password.contains(where: { $0.isLowercase }))
                            requirementRow(text: "Contains a number", met: password.contains(where: { $0.isNumber }))
                        }
                        .padding(16)
                        .background(cream.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: burgundy.opacity(0.08), radius: 30, x: 0, y: 15)
                    )
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.7).delay(0.4), value: isAnimating)
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { isAnimating = true }
    }
    
    private func requirementRow(text: String, met: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(met ? burgundy : .gray.opacity(0.4))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(met ? burgundy : .gray)
        }
    }
    
    private func luxuryTextField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(burgundy.opacity(0.6))
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 16))
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 16))
            }
        }
        .padding()
        .background(cream.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(burgundy.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func register() {
        guard validatePasswords() else { return }
        
        if selectedRole == "User" {
            authViewModel.registerUser(fullName: fullName, email: email, password: password) { error in
                if let error = error {
                    print("Client registration failed: \(error.localizedDescription)")
                } else {
                    print("Client registered successfully")
                }
            }
        } else {
            authViewModel.registerRestaurant(
                name: restaurantName,
                location: restaurantLocation,
                email: email,
                password: password,
                imageUrl: "https://i.postimg.cc/9Mcxx9bg/temp-Image9v-IU3J.avif"
            ) { error in
                if let error = error {
                    print("Restaurant registration failed: \(error.localizedDescription)")
                } else {
                    print("Restaurant registered successfully")
                }
            }
        }
    }
    
    private func validatePasswords() -> Bool {
        if password != confirmPassword {
            withAnimation { passwordError = "Passwords do not match."; showPasswordError = true }
            return false
        } else if password.count < 8 {
            withAnimation { passwordError = "Password must be at least 8 characters long."; showPasswordError = true }
            return false
        } else if !password.contains(where: { $0.isUppercase }) ||
                    !password.contains(where: { $0.isLowercase }) ||
                    !password.contains(where: { $0.isNumber }) {
            withAnimation { passwordError = "Password must include upper, lower case letters and a number."; showPasswordError = true }
            return false
        }
        
        withAnimation { showPasswordError = false }
        return true
    }
}
