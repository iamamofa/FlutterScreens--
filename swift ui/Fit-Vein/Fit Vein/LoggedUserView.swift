//
//  LoggedUserView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var workoutViewModel = WorkoutViewModel(forPreviews: false)
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var medalsViewModel = MedalsViewModel()
    @StateObject private var networkManager = NetworkManager()
    
    @AppStorage("isTabBarHidden") var isTabBarHidden: Bool = false
    
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    @State private var shouldShowOnboardingState: Bool = false
    
    @State var selectedTab: Tab = .home
    
    enum Tab: String {
        case home
        case workout
        case profile
    }
    
    private var tabItems = [
        TabItem(text: String(localized: "LoggedUserView_home_tab_label"), icon: "house", tab: .home),
        TabItem(text: String(localized: "LoggedUserView_workout_tab_label"), icon: "figure.walk", tab: .workout),
        TabItem(text: String(localized: "LoggedUserView_profile_tab_label"), icon: "person", tab: .profile)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Group {
                switch selectedTab {
                case .home:
                    withAnimation(.linear) {
                        HomeView()
                            .environmentObject(homeViewModel)
                            .environmentObject(profileViewModel)
                            .environmentObject(medalsViewModel)
                            .environmentObject(networkManager)
                            .onAppear {
                                UserDefaults.standard.set(false, forKey: "isTabBarHidden")
                            }
                    }
                case .workout:
                    withAnimation(.linear) {
                        WorkoutView()
                            .environmentObject(workoutViewModel)
                            .environmentObject(medalsViewModel)
                            .environmentObject(networkManager)
                            .onAppear {
                                UserDefaults.standard.set(false, forKey: "isTabBarHidden")
                            }
                    }
                case .profile:
                    withAnimation(.linear) {
                        ProfileView()
                            .environmentObject(profileViewModel)
                            .environmentObject(medalsViewModel)
                            .environmentObject(networkManager)
                            .onAppear {
                                UserDefaults.standard.set(false, forKey: "isTabBarHidden")
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                
                ForEach(tabItems) { tabItem in
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tabItem.tab
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Image(systemName: tabItem.icon)
                                .symbolVariant(.fill)
                                .font(.body.bold())
                                .frame(width: 44, height: 29)
                            Text(tabItem.text)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedTab == tabItem.tab ? .accentColor : Color(uiColor: .systemGray))
                    }
                    .foregroundStyle(selectedTab == tabItem.tab ? .primary : .secondary)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal, 7)
            .padding(.top, 10)
            .frame(height: screenHeight * 0.11, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(
                HStack {
                    if selectedTab == .workout {
                        Spacer()
                    }
                    
                    if selectedTab == .profile {
                        Spacer()
                    }
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.007)
                        .cornerRadius(3)
                        .frame(width: screenWidth * 0.235)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    if selectedTab == .home {
                        Spacer()
                    }
                    
                    if selectedTab == .workout {
                        Spacer()
                    }
                }
                .padding(selectedTab == .home ? .leading : .trailing, selectedTab == .workout ? 0 : screenWidth * 0.074)
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .isHidden(isTabBarHidden)
        }
        .onAppear {
            self.shouldShowOnboardingState = shouldShowOnboarding
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding, onDismiss: {
            shouldShowOnboarding = false
            shouldShowOnboardingState = false
        }, content: {
            OnboardingView()
        })
    }
    
    struct TabItem: Identifiable {
        var id = UUID()
        var text: String
        var icon: String
        var tab: Tab
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                LoggedUserView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
