import SwiftUI
import Firebase

// MARK: - Login View
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showRegister = false
    @State private var navigateToDashboard = false
    @State private var role: String = ""
    @State private var loginError = ""
    @State private var isAnimating = false
    
    private let burgundy = Color(red: 0.5, green: 0.13, blue: 0.13)
    private let deepBurgundy = Color(red: 0.35, green: 0.09, blue: 0.09)
    private let cream = Color(red: 0.98, green: 0.97, blue: 0.95)
    private let gold = Color(red: 0.85, green: 0.65, blue: 0.13)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background
                LinearGradient(
                    colors: [cream, Color.white, cream],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Decorative circles
                Circle()
                    .fill(burgundy.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: -150, y: -250)
                
                Circle()
                    .fill(gold.opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 180, y: 350)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 60)
                        
                        // Logo/Brand Area
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [burgundy, deepBurgundy],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .shadow(color: burgundy.opacity(0.4), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 38, weight: .light))
                                    .foregroundColor(cream)
                            }
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)
                            
                            Text("Welcome Back")
                                .font(.system(size: 36, weight: .light, design: .serif))
                                .foregroundColor(deepBurgundy)
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                            
                            Text("Sign in to continue your culinary journey")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.gray)
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                        }
                        .padding(.bottom, 50)
                        
                        // Main Card
                        VStack(spacing: 28) {
                            luxuryTextField(
                                icon: "envelope",
                                placeholder: "Email Address",
                                text: $email
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            luxuryTextField(
                                icon: "lock",
                                placeholder: "Password",
                                text: $password,
                                isSecure: true
                            )
                            
                            if !loginError.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    Text(loginError)
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.horizontal)
                                .transition(.opacity)
                            }
                            
                            Button(action: loginUser) {
                                HStack(spacing: 12) {
                                    Text("Sign In")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [burgundy, deepBurgundy],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: burgundy.opacity(0.4), radius: 15, x: 0, y: 8)
                            }
                            .padding(.top, 8)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                Text("or")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)
                            
                            Button(action: { showRegister = true }) {
                                HStack(spacing: 8) {
                                    Text("New here?")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                    Text("Create Account")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(burgundy)
                                }
                            }
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
                        .animation(.easeOut(duration: 0.7).delay(0.5), value: isAnimating)
                        
                        Spacer().frame(height: 40)
                    }
                }
                
                NavigationLink(destination: RegisterView(), isActive: $showRegister) { EmptyView() }
                NavigationLink(
                    destination: role == "client" ? AnyView(ChoicesView()) : AnyView(RestaurantDashboardView()),
                    isActive: $navigateToDashboard
                ) { EmptyView() }
            }
            .navigationBarHidden(true)
        }
        .onAppear { isAnimating = true }
    }
    
    func loginUser() {
        authVM.login(email: email, password: password) { error in
            if let error = error {
                withAnimation { loginError = error.localizedDescription }
                return
            }
            guard let uid = authVM.userSession?.uid else { return }
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { userSnap, _ in
                if let userData = userSnap?.data(), let userRole = userData["role"] as? String {
                    role = userRole
                    navigateToDashboard = true
                } else {
                    db.collection("restaurants").whereField("ownerID", isEqualTo: uid).getDocuments { snapshot, _ in
                        if snapshot?.documents.first != nil {
                            role = "restaurant"
                            navigateToDashboard = true
                        } else {
                            withAnimation { loginError = "User role not found." }
                        }
                    }
                }
            }
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
}
