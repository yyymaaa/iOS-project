import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var restaurantVM = RestaurantViewModel()
    @State private var searchText = ""
    @State private var currentIndex = 0
    let carouselTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurantVM.restaurants
        } else {
            return restaurantVM.restaurants.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    HStack {
                        Text("Where do you want to eat today?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        
                        Button(action: { print("Cart tapped") }) {
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        
                        Button(action: { print("Profile tapped") }) {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Carousel
                    ZStack {
                        if !restaurantVM.restaurants.isEmpty {
                            AsyncImage(url: URL(string: restaurantVM.restaurants[currentIndex].imageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipped()
                                    .cornerRadius(20)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 220)
                                    .cornerRadius(20)
                            }
                            .onReceive(carouselTimer) { _ in
                                withAnimation {
                                    currentIndex = (currentIndex + 1) % restaurantVM.restaurants.count
                                }
                            }
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 220)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search restaurants...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Restaurant List
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(filteredRestaurants) { restaurant in
                            NavigationLink(destination: MealView(restaurant: restaurant)) {
                                VStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(height: 160)
                                    .cornerRadius(15)
                                    .clipped()

                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(restaurant.name)
                                                .font(.headline)
                                            Text(restaurant.location)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .onAppear {
                restaurantVM.fetchRestaurants()
            }
            .navigationBarHidden(true)
        }
    }
}
