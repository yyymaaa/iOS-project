import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isAuthenticated = false
    private var db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.isAuthenticated = userSession != nil
    }

    func registerUser(fullName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                completion(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            // Default profile image for all clients
            let defaultClientImageUrl = "https://i.postimg.cc/yNvzV7DX/temp-Image-AHGp-Cz.avif"
            
            // Save user info in Firestore
            let data: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Timestamp(),
                "role": "client",
                "imageUrl": defaultClientImageUrl
            ]
            
            self.db.collection("users").document(user.uid).setData(data) { error in
                if let error = error {
                    completion(error)
                } else {
                    DispatchQueue.main.async {
                        self.userSession = user
                        self.isAuthenticated = true
                    }
                    completion(nil)
                }
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }

            DispatchQueue.main.async {
                self.userSession = result?.user
                self.isAuthenticated = true
            }
            completion(nil)
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
