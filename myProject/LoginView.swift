import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegister = false

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
                    // Handle login logic later
                    print("Login tapped")
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
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

