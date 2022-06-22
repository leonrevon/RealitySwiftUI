//
//  RealityUIKitApp.swift
//  RealityUIKit
//
//  Created by Leon Teng on 10.06.22.
//

import SwiftUI
import Firebase

@main
struct RealityUIKitApp: App {
    
    @StateObject var placementSetting = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var sceneManager = SceneManager()
    @StateObject var modelsViewModel = ModelsViewModel()
    
    init(){
        FirebaseApp.configure()
        
        //Anonymouse authentication with Firebase
        Auth.auth().signInAnonymously { authResult, error in
            guard let  user = authResult?.user else {
                print("Failed to Authenticate!")
                return
            }
            
            let uid = user.uid
            print("Firebase: Anonymouse user authentication with uid: \(uid).")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSetting)
                .environmentObject(sessionSettings)
                .environmentObject(sceneManager)
                .environmentObject(modelsViewModel)
        }
    }
}
