//
//  ControlView.swift
//  RealityUIKit
//
//  Created by Leon Teng on 10.06.22.
//

import SwiftUI
import RealityKit


enum ControlModes: String, CaseIterable {
    case browse
    case scene
}

struct ControlView: View {
    
    @Binding var selectedControlMode: Int
    @Binding var isControlsVisible: Bool
    @Binding var isBrowseVisible: Bool
    @Binding var showSetting: Bool
    
    var body: some View {
        
        VStack {
            
            ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
            
            Spacer()
            
            if isControlsVisible{
                ControlModePicker(selectedControlMode: $selectedControlMode)
                ControlButtonBar(isBrowseVisible: $isBrowseVisible, showSetting: $showSetting, selectedControlMode: selectedControlMode)
            }                        
        }
    }
}


struct ControlVisibilityToggleButton: View {
    @Binding var isControlsVisible: Bool
    
    var body: some View {
        HStack {
            
            Spacer()
            
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("Control Visibility Button pressed.")
                    self.isControlsVisible.toggle()
                }) {
                    Image(systemName: self.isControlsVisible ? "rectangle" : "slider.horizontal.below.rectangle")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        
        .padding(.top, 45)
        .padding(.trailing, 20)
        
    }
}

struct ControlModePicker: View {
    @Binding var selectedControlMode: Int
    let controlModes = ControlModes.allCases
        
    init(selectedControlMode: Binding<Int>) {
        self._selectedControlMode = selectedControlMode
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.yellow], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.black.opacity(0.25))
        
    }
    var body: some View {
        Picker(selection: $selectedControlMode, label: Text("Select a Control Mode")) {
            ForEach(0..<controlModes.count) {index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: .greatestFiniteMagnitude)
        .padding(.horizontal, 10)
    }
}

struct ControlButtonBar: View {
    
    @Binding var isBrowseVisible: Bool
    @Binding var showSetting: Bool
    var selectedControlMode: Int

    var body: some View {
        
        HStack(alignment: .center) {
            if selectedControlMode == 1 {
                SceneButton()
            } else {
                BrowseButtons(isBrowseVisible: $isBrowseVisible, showSetting: $showSetting)
            }
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct BrowseButtons: View {
    
    @EnvironmentObject var placementSetting: PlacementSettings
    @Binding var isBrowseVisible: Bool
    @Binding var showSetting: Bool
    
    var body: some View {
        HStack {
            
            //MostRecentlyPlaced Button
            MostRecentlyPlacedButton().hidden(self.placementSetting.recentlyPlaced.isEmpty)
            
            Spacer()
            
            //Browse Button
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse button pressed.")
                self.isBrowseVisible.toggle()
            }.sheet(isPresented: $isBrowseVisible) {
                BrowseView(isBrowseVisible: $isBrowseVisible)
                    .environmentObject(placementSetting)
            }
            
            Spacer()
            
            //Settings Button
            ControlButton(systemIconName: "slider.horizontal.3") {
                print("Settings button pressed.")
                self.showSetting.toggle()
            }.sheet(isPresented: $showSetting) {
                SettingView(showSettings: $showSetting)
            }
            
        }
    }
}

struct SceneButton: View {
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        
        ControlButton(systemIconName: "icloud.and.arrow.up") {
            print("Save Scene Button Pressed")
            self.sceneManager.shouldSaveSceneToFileSystem = true
        }
        .hidden(!self.sceneManager.isPersistenceAvailable)
        
        Spacer()
        
        ControlButton(systemIconName: "icloud.and.arrow.down") {
            print("Load Scene Button Pressed")
            self.sceneManager.shouldLoadSceneFromFileSystem = true
        }
        .hidden(self.sceneManager.scenePersistenceData == nil)
        
        Spacer()
        
        ControlButton(systemIconName: "trash") {
            print("Clear Scene Button Pressed")
        }
    }
}

struct ControlButton: View {
    
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSetting: PlacementSettings
    
    var body: some View {
        Button(action: {
            print("Most Recently Placed Button Pressed")
            self.placementSetting.selectedModel = self.placementSetting.recentlyPlaced.last
        }) {
            if let mostRecentlyPlacedModel = self.placementSetting.recentlyPlaced.last {
                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .aspectRatio(contentMode: .fit)
                    .background(.white)
                    .cornerRadius(8.0)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
