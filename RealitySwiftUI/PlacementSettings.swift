//
//  PlacementSettings.swift
//  RealityUIKit
//
//  Created by Leon Teng on 14.06.22.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor {
    var model: Model
    var anchor: ARAnchor?
}


class PlacementSettings: ObservableObject {
    
    
    // When user selected in BrowseView, the property is set
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("Selected Model to \(String(describing: newValue?.name))")
        }
    }
    
    //// When the user taps confirm in PlacementView, the value of selected Model is assigned to ConfirmModel
//    @Published var confirmedModel: Model? {
//        willSet(newValue){
//            guard let model = newValue else {
//                print("cleared ConfirmedModel")
//                return
//            }
//
//            print("Confirmed Model set to \(model.name)")
//            self.recentlyPlaced.append(model)
//        }
//    }
    
    // This property will keep track of all the content that has been confirmed for placement
    var modelsConfirmedForPlacement: [ModelAnchor] = []
    
    // Retains a record of placed models in the scene. The last element in the array is the most recently placed model.
    @Published var recentlyPlaced: [Model] = []
    // retains the cancellable object for SceneEvents.Update subscriber
    var sceneObserver: Cancellable?
}
