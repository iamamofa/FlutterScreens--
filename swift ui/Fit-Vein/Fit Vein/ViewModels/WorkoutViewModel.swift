//
//  WorkoutViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation
import SwiftUI

@MainActor
class WorkoutViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    @Published var workout: IntervalWorkout?
    @Published var workoutsList: [IntervalWorkout] = [IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 200, series: 8, workTime: 45,                                                        restTime: 15),
                                                       IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 260, series: 10, workTime: 30, restTime: 15),
                                                       IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 140, series: 5, workTime: 60, restTime: 30),
                                                       IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 110, series: 7, workTime: 45, restTime: 20),
                                                       IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 260, series: 8, workTime: 45, restTime: 20)]
    @AppStorage("usersWorkoutsList") var usersWorkoutsList: [IntervalWorkout] = []
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    init(forPreviews: Bool) {
        if forPreviews {
            self.workout = IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 0, series: 8, workTime: 45, restTime: 15)
        }
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func startWorkout(workout: IntervalWorkout) {
        self.workout = workout
    }

    func stopWorkout(calories: Int, completedDuration: Int, completedSeries: Int) {
        self.workout?.setDataOnEnd(calories: calories, completedDuration: completedDuration, completedSeries: completedSeries)
    }
    
    func saveWorkoutToDatabase(completion: @escaping ((Bool) -> ())) {
        if self.workout != nil {
            if self.sessionStore.currentUser != nil {
                self.workout!.setUsersID(usersID: self.sessionStore.currentUser!.uid)
                self.firestoreManager.workoutDataCreation(id: workout!.id, usersID: workout!.usersID, type: workout!.type, date: workout!.date, isFinished: workout!.isFinished, calories: workout!.calories, series: workout!.series, workTime: workout!.workTime, restTime: workout!.restTime, completedDuration: workout!.completedDuration, completedSeries: workout!.completedSeries) { success in
                    if success {
                        print("Successfully saved workout to the database.")
                        completion(true)
                    } else {
                        print("Error saving workout to the database.")
                        completion(false)
                    }
                }
            } else {
                completion(false)
                print("Error saving workout to the database: current user is nil")
            }
        }
    }
    
    func addUserWorkout(series: Int, workTime: Int, restTime: Int) {
        self.usersWorkoutsList.append(IntervalWorkout(id: UUID().uuidString, usersID: "9999", type: "Interval", date: Date(), isFinished: false, calories: 200, series: series, workTime: workTime, restTime: restTime))
    }
    
    func deleteUserWorkout(indexSet: IndexSet) {
        self.usersWorkoutsList.remove(atOffsets: indexSet)
    }
}


