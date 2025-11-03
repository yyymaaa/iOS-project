import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Color Palette Extension
extension Color {
    static let luxBurgundy = Color(red: 0.5, green: 0.13, blue: 0.13)
    static let luxDeepBurgundy = Color(red: 0.35, green: 0.09, blue: 0.09)
    static let luxLightBurgundy = Color(red: 0.7, green: 0.2, blue: 0.2)
    static let luxCream = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let luxGold = Color(red: 0.85, green: 0.65, blue: 0.13)
}

// MARK: - Home View
struct HomeView: View {
    @StateObject private var restaurantVM = RestaurantViewModel()
    @EnvironmentObject var cartManager: CartManager
    @State private var searchText = ""
    @State private var currentIndex = 0
    @State private var isAnimating = false
    let carouselTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurantVM.restaurants
        } else {
            return restaurantVM.restaurants.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.luxCream.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        headerSection
                        carouselSection
                        searchSection
                        restaurantSection
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                restaurantVM.fetchRestaurants()
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Discover")
                        .font(.system(size: 38, weight: .light, design: .serif))
                        .foregroundColor(.luxDeepBurgundy)
                    
                    Text("Where would you like to dine today?")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(x: isAnimating ? 0 : -20)
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Orders Button - NEW
                    NavigationLink(destination: MyOrdersView()) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.system(size: 20))
                            .foregroundColor(.luxBurgundy)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .luxBurgundy.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    
                    NavigationLink(destination: CartView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bag")
                                .font(.system(size: 22))
                                .foregroundColor(.luxBurgundy)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .luxBurgundy.opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            if !cartManager.cartItems.isEmpty {
                                Circle()
                                    .fill(Color.luxGold)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text("\(cartManager.cartItems.count)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.luxBurgundy)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .luxBurgundy.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(x: isAnimating ? 0 : 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.luxBurgundy, .luxBurgundy.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(width: 140)
                .padding(.leading, 24)
                .opacity(isAnimating ? 1 : 0)
        }
    }
    
    // MARK: - Carousel Section
    private var carouselSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !restaurantVM.restaurants.isEmpty {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: restaurantVM.restaurants[currentIndex].imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.luxBurgundy.opacity(0.1)
                    }
                    .frame(height: 260)
                    .clipped()
                    .cornerRadius(24)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .cornerRadius(24)
                    )
                    .onReceive(carouselTimer) { _ in
                        withAnimation(.spring(response: 0.6)) {
                            currentIndex = (currentIndex + 1) % restaurantVM.restaurants.count
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(restaurantVM.restaurants[currentIndex].name)
                            .font(.system(size: 28, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text(restaurantVM.restaurants[currentIndex].location)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(24)
                }
                .shadow(color: .luxBurgundy.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // Carousel Indicators
                HStack(spacing: 8) {
                    ForEach(0..<min(restaurantVM.restaurants.count, 5), id: \.self) { index in
                        Capsule()
                            .fill(currentIndex == index ? Color.luxBurgundy : Color.gray.opacity(0.3))
                            .frame(width: currentIndex == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentIndex)
                    }
                }
                .padding(.leading, 24)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.luxBurgundy.opacity(0.1))
                    .frame(height: 260)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.2)
                    )
            }
        }
        .padding(.horizontal, 24)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
        .animation(.easeOut(duration: 0.7).delay(0.2), value: isAnimating)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.luxBurgundy.opacity(0.6))
            
            TextField("Search for restaurants...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.luxDeepBurgundy)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.luxBurgundy.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .luxBurgundy.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 24)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.7).delay(0.3), value: isAnimating)
    }
    
    // MARK: - Restaurant Section
    private var restaurantSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Featured Restaurants")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(.luxDeepBurgundy)
                
                Spacer()
                
                Text("\(filteredRestaurants.count) places")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            
            LazyVStack(spacing: 20) {
                ForEach(filteredRestaurants) { restaurant in
                    NavigationLink(destination: MealView(restaurant: restaurant).environmentObject(cartManager)) {
                        restaurantCard(restaurant)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 30)
        .animation(.easeOut(duration: 0.7).delay(0.4), value: isAnimating)
    }
    
    private func restaurantCard(_ restaurant: Restaurant) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.luxBurgundy.opacity(0.1)
            }
            .frame(height: 180)
            .clipped()
            
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.system(size: 19, weight: .semibold, design: .serif))
                        .foregroundColor(.luxDeepBurgundy)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.luxBurgundy.opacity(0.7))
                        Text(restaurant.location)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.luxBurgundy)
            }
            .padding(20)
            .background(Color.white)
        }
        .cornerRadius(20)
        .shadow(color: .luxBurgundy.opacity(0.1), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.luxBurgundy.opacity(0.1), lineWidth: 1)
        )
    }
}
