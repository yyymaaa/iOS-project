import SwiftUI

struct RestaurantRegisterView: View {
    @State private var name = ""
    @State private var location = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var imageUrl = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Register Restaurant")
                .font(.largeTitle).bold()
            
            TextField("Restaurant Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Location", text: $location).textFieldStyle(.roundedBorder)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder).keyboardType(.emailAddress).autocapitalization(.none)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirm Password", text: $confirmPassword).textFieldStyle(.roundedBorder)
            TextField("Image URL", text: $imageUrl).textFieldStyle(.roundedBorder)
            
            if showError {
                Text(errorMessage).foregroundColor(.red)
            }
            
            Button("Register") {
                registerRestaurant()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    func registerRestaurant() {
        guard password == confirmPassword else { errorMessage = "Passwords do not match."; showError = true; return }
        
        authVM.registerRestaurant(name: name, location: location, email: email, password: password, imageUrl: imageUrl) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
