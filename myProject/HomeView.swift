import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome, Amy!")
                    Text("Discover Restaurants")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(1..<4) { index in
                                Image("banner\(index)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 150)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("Popular Restaurants")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        ForEach(1..<4) { index in
                            HStack(spacing: 16) {
                                Image("Restaurant\(index)")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Restaurant \(index)")
                                        .font(.headline)
                                    Text("Italian")
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text("4.\(index)")
                                            .foregroundColor(.gray)
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
}
