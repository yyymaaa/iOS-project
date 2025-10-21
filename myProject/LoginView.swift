import SwiftUI


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegister = false
    @EnvironmentObject var AuthViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    AuthViewModel.login(email:email, password: password) { error in
                        if let error = error {
                            print("Login failed: \(error.localizedDescription)")
                        } else {
                            print("Login Successful")
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                HStack {
                    Text("Don't have an account?")
                    Button(action: {
                        isShowingRegister = true
                    }) {
                        Text("Register")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 20)

                // Navigation link (hidden) to show RegisterView
                NavigationLink(destination: RegisterView(), isActive: $isShowingRegister) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

