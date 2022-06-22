//
//  PlacementView.swift
//  RealityUIKit
//
//  Created by Leon Teng on 14.06.22.
//

import SwiftUI



struct PlacementView: View {
    @EnvironmentObject var placementSetting: PlacementSettings
    
    var body: some View {
        HStack {
            
            Spacer()
            
            PlacementButton(systemIconName: "xmark.circle.fill") {
                print("Cancel Placement Button Pressed")
                self.placementSetting.selectedModel = nil 
            }
            
            Spacer()
            
            PlacementButton(systemIconName: "checkmark.circle.fill") {
                print("Confirmed Placement Button Pressed")
                
                let modelAnchor = ModelAnchor(model: self.placementSetting.selectedModel!, anchor: nil)
                self.placementSetting.modelsConfirmedForPlacement.append(modelAnchor)
                self.placementSetting.selectedModel = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}
struct PlacementButton: View{
    
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }){
            Image(systemName: systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)
    }
}
