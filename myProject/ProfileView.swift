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
    @State private var isAnimating = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phoneNumber = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.luxCream, Color.white, .luxCream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color.luxBurgundy.opacity(0.04))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(Color.luxGold.opacity(0.06))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: 180, y: 300)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    profileImageSection
                    profileDetailsCard
                    actionsSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.luxBurgundy.opacity(0.1), .luxGold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                if let url = URL(string: imageUrl), !imageUrl.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.luxBurgundy.opacity(0.1)
                    }
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.luxBurgundy, .luxDeepBurgundy],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                
                Circle()
                    .stroke(Color.luxBurgundy.opacity(0.3), lineWidth: 2)
                    .frame(width: 140, height: 140)
            }
            .shadow(color: .luxBurgundy.opacity(0.2), radius: 20, x: 0, y: 10)
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
            
            Text("Your Profile")
                .font(.system(size: 32, weight: .light, design: .serif))
                .foregroundColor(.luxDeepBurgundy)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
        }
    }
    
    private var profileDetailsCard: some View {
        VStack(spacing: 24) {
            luxuryField(title: "Full Name", text: $fullName, editable: isEditing)
            luxuryField(title: "Email Address", text: $email, editable: false)
            luxuryField(title: "Phone Number", text: $phoneNumber, editable: isEditing)
                        .keyboardType(.phonePad)
            luxuryField(title: "Role", text: $role, editable: isEditing)
            
            if isEditing {
                luxuryField(title: "Profile Image URL", text: $imageUrl, editable: true)
            }
            
            if !message.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.luxBurgundy)
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.luxBurgundy)
                }
                .padding(12)
                .background(Color.luxBurgundy.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(28)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .luxBurgundy.opacity(0.08), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
        )
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
        .animation(.easeOut(duration: 0.7).delay(0.2), value: isAnimating)
    }
    
    private func luxuryField(title: String, text: Binding<String>, editable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.luxBurgundy.opacity(0.7))
                .tracking(1)
            
            TextField("", text: text)
                .disabled(!editable)
                .font(.system(size: 16))
                .foregroundColor(.luxDeepBurgundy)
                .padding(16)
                .background(editable ? .luxCream : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(editable ? Color.luxBurgundy.opacity(0.3) : .luxBurgundy.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: MyOrdersView()) {
                HStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.luxBurgundy)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Receipts")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.luxDeepBurgundy)
                        
                        Text("View your order history and receipts")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.luxBurgundy.opacity(0.6))
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .luxBurgundy.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(spacing: 16) {
                Button(action: {
                    if isEditing { saveChanges() }
                    withAnimation(.spring(response: 0.3)) {
                        isEditing.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 18))
                        Text(isEditing ? "Save Changes" : "Edit Profile")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.luxBurgundy, .luxDeepBurgundy],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .luxBurgundy.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 18))
                        Text("Sign Out")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.luxDeepBurgundy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.luxBurgundy.opacity(0.2), lineWidth: 1.5)
                    )
                    .shadow(color: .luxBurgundy.opacity(0.08), radius: 12, x: 0, y: 4)
                }
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.7).delay(0.3), value: isAnimating)
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { doc, _ in
            if let data = doc?.data() {
                fullName = data["fullName"] as? String ?? ""
                email = data["email"] as? String ?? ""
                role = data["role"] as? String ?? ""
                imageUrl = data["imageUrl"] as? String ?? ""
                phoneNumber = data["phoneNumber"] as? String ?? ""
            }
        }
    }
    
    private func saveChanges() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "fullName": fullName,
            "role": role,
            "imageUrl": imageUrl,
            "phoneNumber": phoneNumber
        ]) { error in
            withAnimation {
                message = error == nil ? "Profile updated successfully!" : "Failed to update profile"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    message = ""
                }
            }
        }
    }
}
