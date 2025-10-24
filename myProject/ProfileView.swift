import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var role = ""
    @State private var imageUrl = ""
    @State private var isEditing = false
    @State private var message = ""

    var body: some View {
        ZStack {
            // Futuristic Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0, green: 0.2, blue: 0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {

                    // Profile Image with Glow
                    ZStack {
                        if let url = URL(string: imageUrl), !imageUrl.isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 130, height: 130)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 130, height: 130)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                        .foregroundColor(.white.opacity(0.6))
                                )
                        }

                        Circle()
                            .stroke(Color.green.opacity(0.8), lineWidth: 3)
                            .blur(radius: 5)
                            .shadow(color: Color.green, radius: 10)
                    }
                    .padding(.top, 50)

                    Text("User Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.green)
                        .shadow(color: .green, radius: 10)

                    // Glass Card
                    VStack(spacing: 18) {
                        futuristicField(title: "Full Name", text: $fullName, editable: isEditing)
                        futuristicField(title: "Email", text: $email, editable: false)
                        futuristicField(title: "Role", text: $role, editable: isEditing)
                        if isEditing {
                            futuristicField(title: "Profile Image URL", text: $imageUrl, editable: true)
                        }

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .padding(.top, 6)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial.opacity(0.3))
                    .cornerRadius(20)
                    .shadow(color: .green.opacity(0.4), radius: 20)
                    .padding(.horizontal)

                    // Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            if isEditing { saveChanges() }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isEditing.toggle()
                            }
                        }) {
                            futuristicButton(text: isEditing ? "Save Changes" : "Edit Profile", color: .green)
                        }

                        Button(action: signOut) {
                            futuristicButton(text: "Sign Out", color: .gray)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear(perform: loadUserData)
    }

    //  Custom UI Elements

    func futuristicField(title: String, text: Binding<String>, editable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.green.opacity(0.8))
            TextField(title, text: text)
                .disabled(!editable)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(editable ? Color.green : Color.white.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
    }

    func futuristicButton(text: String, color: Color) -> some View {
        Text(text)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.4)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: color, radius: 10)
            .foregroundColor(.black)
            .padding(.horizontal)
    }

    // MARK: - Firebase Logic

    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { doc, _ in
            if let data = doc?.data() {
                fullName = data["fullName"] as? String ?? ""
                email = data["email"] as? String ?? ""
                role = data["role"] as? String ?? ""
                imageUrl = data["imageUrl"] as? String ?? ""
            }
        }
    }

    private func saveChanges() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "fullName": fullName,
            "role": role,
            "imageUrl": imageUrl
        ]) { error in
            message = error == nil ? "Profile updated!" : "Oops! Something went wrong updating!"
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            message = "Signed out successfully."
        } catch {
            message = "Sign-out failed."
        }
    }
}
