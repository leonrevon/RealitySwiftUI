//
//  ContentView.swift
//  RealityUIKit
//
//  Created by Leon Teng on 10.06.22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var placementSetting: PlacementSettings
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    @State private var selectedControlMode: Int = 0
    @State private var isControlsVisible: Bool = true
    @State private var isBrowseVisible: Bool = false
    @State private var showSettings: Bool = false
    var body: some View {
       
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            if self.placementSetting.selectedModel == nil {
                ControlView(selectedControlMode: $selectedControlMode, isControlsVisible: $isControlsVisible, isBrowseVisible: $isBrowseVisible, showSetting: $showSettings)
            } else {
                PlacementView()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            self.modelsViewModel.fetchData()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
            .environmentObject(SceneManager())
            .environmentObject(ModelsViewModel())
    }
}
