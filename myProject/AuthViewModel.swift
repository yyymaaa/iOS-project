import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var role: String? // Added to store current user role
    
    private var db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.isAuthenticated = userSession != nil
        if let uid = userSession?.uid {
            fetchUserRole(uid: uid)
        }
    }
    
    // MARK: - Client Registration
    func registerUser(fullName: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { completion(error); return }
            guard let user = result?.user else {
                completion(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let defaultClientImageUrl = "https://i.postimg.cc/yNvzV7DX/temp-Image-AHGp-Cz.avif"
            
            let data: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Timestamp(),
                "role": "client",
                "imageUrl": defaultClientImageUrl
            ]
            
            self.db.collection("users").document(user.uid).setData(data) { error in
                if let error = error { completion(error); return }
                DispatchQueue.main.async {
                    self.userSession = user
                    self.isAuthenticated = true
                    self.role = "client"
                }
                completion(nil)
            }
        }
    }
    
    // MARK: - Restaurant Registration
    func registerRestaurant(name: String, location: String, email: String, password: String, imageUrl: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { completion(error); return }
            guard let user = result?.user else { completion(NSError(domain: "", code: -1, userInfo: nil)); return }
            
            let data: [String: Any] = [
                "name": name,
                "location": location,
                "imageUrl": imageUrl,
                "ownerID": user.uid,
                "createdAt": Timestamp()
            ]
            
            self.db.collection("restaurants").document().setData(data) { error in
                if let error = error { completion(error); return }
                DispatchQueue.main.async {
                    self.userSession = user
                    self.isAuthenticated = true
                    self.role = "restaurant"
                }
                completion(nil)
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { completion(error); return }
            guard let user = result?.user else { completion(NSError(domain: "", code: -1, userInfo: nil)); return }
            
            self.userSession = user
            self.isAuthenticated = true
            
            // Fetch role from Firestore
            self.fetchUserRole(uid: user.uid, completion: completion)
        }
    }
    
    // MARK: - Fetch Role
    private func fetchUserRole(uid: String, completion: ((Error?) -> Void)? = nil) {
        // Check in users collection first
        db.collection("users").document(uid).getDocument { userSnap, error in
            if let error = error { completion?(error); return }
            if let data = userSnap?.data(), let userRole = data["role"] as? String {
                DispatchQueue.main.async { self.role = userRole }
                completion?(nil)
            } else {
                // Check in restaurants collection
                self.db.collection("restaurants").whereField("ownerID", isEqualTo: uid).getDocuments { snapshot, error in
                    if let error = error { completion?(error); return }
                    if let doc = snapshot?.documents.first {
                        DispatchQueue.main.async { self.role = "restaurant" }
                        completion?(nil)
                    } else {
                        completion?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Role not found"]))
                    }
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.isAuthenticated = false
            self.role = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
