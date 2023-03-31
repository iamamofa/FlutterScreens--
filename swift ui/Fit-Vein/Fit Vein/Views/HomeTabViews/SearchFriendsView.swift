//
//  SearchFriendsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import SwiftUI

struct SearchFriendsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @State var searching = false
    @State var searchText = ""
    
    @State private var success = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                VStack {
                    if let usersData = self.homeViewModel.usersData {
                        List {
                            ForEach(searchResults, id: \.self) { userID in
                                HStack {
                                    Group {
                                        if let usersProfilePicturesURLs = self.homeViewModel.usersProfilePicturesURLs {
                                            AsyncImage(url: usersProfilePicturesURLs[userID]) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                } else {
                                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                        .resizable()
                                                }
                                            }
                                        } else {
                                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                .resizable()
                                        }
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                    
                                    VStack() {
                                        Spacer()
                                        
                                        if let userData = usersData[userID] {
                                            HStack {
                                                Text(userData[0])
                                                    .foregroundColor(.accentColor)
                                                    .font(.system(size: screenHeight * 0.025, weight: .bold))
                                                    .padding(.bottom, screenHeight * 0.002)
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Text(userData[1])
                                                    .foregroundColor(Color(uiColor: .systemGray3))
                                                Spacer()
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, screenWidth * 0.03)
                                    
                                    Spacer(minLength: screenWidth * 0.15)
                                    
                                    if self.profileViewModel.profile!.followedIDs != nil {
                                        if self.profileViewModel.profile!.followedIDs!.contains(userID) {
                                            Button(action: {
                                                self.profileViewModel.unfollowUser(userID: userID) { success in
                                                    if success {
                                                        self.homeViewModel.fetchData()
                                                    }
                                                    self.success = success
                                                }
                                            }, label: {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .foregroundColor(Color(uiColor: UIColor(red: 255, green: 204, blue: 209)))
                                                    
                                                    HStack {
                                                        Text(String(localized: "SearchFriendsView_unfollow_button"))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108)))
                                                    }
                                                    .padding(.horizontal)
                                                    .frame(height: screenHeight * 0.05)
                                                }
                                                .frame(width: screenWidth * 0.33, height: screenHeight * 0.05)
                                            })
                                        } else {
                                            Button(action: {
                                                self.profileViewModel.followUser(userID: userID) { success in
                                                    if success {
                                                        self.homeViewModel.fetchData()
                                                    }
                                                    self.success = success
                                                }
                                            }, label: {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .foregroundColor(Color(uiColor: UIColor(red: 180, green: 255, blue: 180)))
                                                    
                                                    HStack {
                                                        Text(String(localized: "SearchFriendsView_follow_button"))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                                                    }
                                                    .padding(.horizontal)
                                                    .frame(height: screenHeight * 0.05)
                                                }
                                                .frame(width: screenWidth * 0.33, height: screenHeight * 0.05)
                                            })
                                        }
                                    } else {
                                        Button(action: {
                                            self.profileViewModel.followUser(userID: userID) { success in
                                                if success {
                                                    self.homeViewModel.fetchData()
                                                }
                                                self.success = success
                                            }
                                        }, label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color(uiColor: UIColor(red: 180, green: 255, blue: 180)))
                                                
                                                HStack {
                                                    Text(String(localized: "SearchFriendsView_follow_button"))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                                                }
                                                .padding(.horizontal)
                                                .frame(height: screenHeight * 0.05)
                                            }
                                            .frame(width: screenWidth * 0.33, height: screenHeight * 0.05)
                                        })
                                    }
                                }
                                .frame(width: screenWidth * 0.9, height: screenHeight * 0.1)
                            }
                            
                            if success {
                                withAnimation(.linear) {
                                    HStack {
                                        Spacer()
                                        LottieView(name: "success", loopMode: .playOnce, contentMode: .scaleAspectFill)
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.07)
                                            .onAppear {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation(.linear) {
                                                        success = false
                                                    }
                                                }
                                            }
                                        Spacer()
                                    }
                                    .padding(.top, screenHeight * 0.1)
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .listStyle(GroupedListStyle())
                        .refreshable {
                            homeViewModel.getAllUsersData()
                        }
                    }
                }
                .navigationTitle(String(localized: "SearchFriendsView_navigation_title"))
                .onAppear {
                    self.homeViewModel.getAllUsersData()
                }
            }
            .navigationViewStyle(.stack)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    var searchResults: [String] {
        if !self.homeViewModel.usersData.isEmpty {
            if searchText.isEmpty {
                return Array(self.homeViewModel.usersData.keys).sorted()
            } else {
                var searchResults = [String]()
                for key in self.homeViewModel.usersData.keys {
                    if let value = self.homeViewModel.usersData[key] {
                        if value[0].lowercased().contains(searchText.lowercased()) || value[1].lowercased().contains(searchText.lowercased()) {
                            searchResults.append(key)
                        }
                    }
                }
                return searchResults
            }
        } else {
            self.homeViewModel.getAllUsersData()
            return [String]()
        }
    }
}

struct SearchFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SearchFriendsView()
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
