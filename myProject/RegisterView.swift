import SwiftUI


struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var passwordError = ""
    @State private var showPasswordError = false
    @EnvironmentObject var AuthViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)

                TextField("Full Name", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if showPasswordError {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: {
                    if validatePasswords() {
                        AuthViewModel.registerUser(fullName: fullName, email: email, password: password) { error in
                            if let error = error {
                                print("Registration failed: \(error.localizedDescription)")
                            } else {
                                print("User registered successfully")
                            }
                        }
                    }
                    
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationTitle("Register")
        }
    }
    
    func validatePasswords() -> Bool {
        if password != confirmPassword {
            passwordError = "Passwords do not match."
            showPasswordError = true
            return false
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
            showPasswordError = true
            return false
        } else if !password.contains(where: { $0.isUppercase }) ||
                    !password.contains(where: { $0.isLowercase }) ||
                    !password.contains(where: { $0.isNumber }) {
            passwordError = "Password must include upper, lower case letters and a number."
            showPasswordError = true
            return false
        }
        
        showPasswordError = false
        return true
    }
}

