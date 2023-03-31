//
//  WorkoutView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var workoutViewModel: WorkoutViewModel
    @EnvironmentObject private var medalsViewModel: MedalsViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    @State var startWorkout = false
    @AppStorage("showSampleWorkoutsList") var showSampleWorkoutsList: Bool = true
    @AppStorage("showUsersWorkoutsList") var showUsersWorkoutsList: Bool = true
    @AppStorage("showSampleWorkoutsListFromSettings") var showSampleWorkoutsListFromSettings: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if startWorkout {
                withAnimation {
                    WorkoutCountdownView()
                        .environmentObject(workoutViewModel)
                        .environmentObject(medalsViewModel)
                        .environmentObject(networkManager)
                }
            } else {
                NavigationView {
                    VStack {
                        List {
                            if showSampleWorkoutsListFromSettings {
                                DisclosureGroup(isExpanded: $showSampleWorkoutsList, content: {
                                    ForEach(workoutViewModel.workoutsList) { workout in
                                        HStack {
                                            Image(uiImage: UIImage(named: "sprint2")!)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text(String(localized: "WorkoutView_interval_training_type"))
                                                    .foregroundColor(.accentColor)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                            }
                                            
                                            Spacer()
                                            
                                            Divider()
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                                                Text("\(String(localized: "WorkoutView_interval_series")): \(workout.series!)")
                                                Text("\(String(localized: "WorkoutView_interval_work_time")): \(workout.workTime!)")
                                                Text("\(String(localized: "WorkoutView_interval_rest_time")): \(workout.restTime!)")
                                            }
                                            
                                            Spacer()
                                        }
                                        .onTapGesture {
                                            withAnimation {
                                                workoutViewModel.workout = workout
                                                startWorkout = true
                                            }
                                        }
                                    }
                                }, label: {
                                    Text(String(localized: "WorkoutView_sample_workouts"))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                })
                            }
                            
                            DisclosureGroup(isExpanded: $showUsersWorkoutsList, content: {
                                ForEach(workoutViewModel.usersWorkoutsList) { workout in
                                    HStack {
                                        Image(uiImage: UIImage(named: "sprint2")!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Text(String(localized: "WorkoutView_interval_training_type"))
                                                .foregroundColor(.accentColor)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                        
                                        Divider()
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                                            Text("\(String(localized: "WorkoutView_interval_series")): \(workout.series!)")
                                            Text("\(String(localized: "WorkoutView_interval_work_time")): \(workout.workTime!)")
                                            Text("\(String(localized: "WorkoutView_interval_rest_time")): \(workout.restTime!)")
                                        }
                                        
                                        Spacer()
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            workoutViewModel.workout = workout
                                            startWorkout = true
                                        }
                                    }
                                }
                                .onDelete { (indexSet) in
                                    workoutViewModel.deleteUserWorkout(indexSet: indexSet)
                                }
                            }, label: {
                                Text(String(localized: "WorkoutView_users_workouts"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                            })
                        }
                    }
                    .navigationTitle(String(localized: "WorkoutView_navigation_title"))
                    .navigationBarHidden(false)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: WorkoutAddView().environmentObject(workoutViewModel).environmentObject(medalsViewModel).navigationTitle(String(localized: "WorkoutAddView_navigation_title")).navigationBarHidden(false).ignoresSafeArea(.keyboard)) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.07)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                .navigationViewStyle(.stack)
            }
        }
    }
}


struct WorkoutAddView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var medalsViewModel: MedalsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var workoutType: String? = "Interval"
    @State var series: String = ""
    @State var workTime: String = ""
    @State var restTime: String = ""
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ScrollView(.vertical) {
                HStack {
                    Spacer()
                    LottieView(name: "runnerAddWorkout", loopMode: .loop)
                        .frame(height: screenHeight * 0.25)
                        .offset(x: screenWidth * 0.25, y: -screenHeight * 0.1)
                }
                .isHidden(isTextFieldFocused)
                
                VStack {
                    VStack {
                        HStack {
                            Text(String(localized: "WorkoutAddView_interval_rounds_number"))
                            Spacer()
                        }
                        
                        VStack {
                            TextField(String(localized: "WorkoutAddView_interval_rounds_unit"), text: $series)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .keyboardType(.numberPad)
                                .focused($isTextFieldFocused)
                            Divider()
                                .background(Color.accentColor)
                        }
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text(String(localized: "WorkoutAddView_interval_work_time"))
                            Spacer()
                        }
                        
                        VStack {
                            TextField(String(localized: "WorkoutAddView_interval_work_time_unit"), text: $workTime)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .keyboardType(.numberPad)
                                .focused($isTextFieldFocused)
                            Divider()
                                .background(Color.accentColor)
                        }
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            Text(String(localized: "WorkoutAddView_interval_rest_time"))
                            Spacer()
                        }
                        
                        VStack {
                            TextField(String(localized: "WorkoutAddView_interval_rest_time_unit"), text: $restTime)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .keyboardType(.numberPad)
                                .focused($isTextFieldFocused)
                            Divider()
                                .background(Color.accentColor)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
                .offset(y: isTextFieldFocused ? -screenHeight * 0.25 : -screenHeight * 0.1)
                .padding()
                
                Button(action: {
                    workoutViewModel.addUserWorkout(series: Int(self.series) ?? 8, workTime: Int(self.workTime) ?? 45, restTime: Int(self.restTime) ?? 15)
                    medalsViewModel.giveUserMedal(medalName: "medalFirstOwnWorkout")
                    dismiss()
                }, label: {
                    Text(String(localized: "WorkoutAddView_save_workout_button"))
                        .foregroundColor(Color(uiColor: .systemGray5))
                        .fontWeight(.bold)
                })
                    .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                    .padding()
                    .offset(y: isTextFieldFocused ? -screenHeight * 0.2 : 0)
                    .disabled(series.isEmpty || workTime.isEmpty || restTime.isEmpty)
            }
            .onDisappear {
                dismiss()
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
        }
    }
}

struct WorkoutCountdownView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject private var medalsViewModel: MedalsViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    
    @State private var startWorkout = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if startWorkout {
                withAnimation(.linear) {
                    WorkoutTimerView()
                        .environmentObject(workoutViewModel)
                        .environmentObject(medalsViewModel)
                        .environmentObject(networkManager)
                }
            } else {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        LottieView(name: "countdown", loopMode: .loop)
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.8)
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .onAppear {
                    UserDefaults.standard.set(true, forKey: "isTabBarHidden")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.linear) {
                            if let workout = workoutViewModel.workout {
                                workoutViewModel.startWorkout(workout: workout)
                            }
                            startWorkout = true
                        }
                    }
                }
            }
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let sessionStore = SessionStore(forPreviews: true)
        let workoutViewModel = WorkoutViewModel(forPreviews: true)
        let networkManager = NetworkManager()
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                WorkoutView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
                    .environmentObject(workoutViewModel)
                    .environmentObject(networkManager)
                
                WorkoutAddView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(workoutViewModel)
                
                WorkoutCountdownView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(workoutViewModel)
                    .environmentObject(networkManager)
            }
        }
    }
}
