import SwiftUI

struct ChoicesView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Jojo's Pizza")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)
                        .foregroundColor(.green)
                    Text("What are you interested in today?")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)
                    
                    VStack(spacing: 16){
                        ForEach(1..<8) { index in
                            HStack(spacing: 16) {
                                Image("Food\(index)")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Food \(index)")
                                        .font(.headline)
                                    Text("Spicy beef burger with fries")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                    Text("KES 0.0")
                                        .foregroundColor(.black)
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
    }
}



