//
//  ARViewContainer.swift
//  RealityUIKit
//
//  Created by Leon Teng on 15.06.22.
//

import Foundation
import RealityKit
import SwiftUI
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
        
        arView.session.delegate = context.coordinator
        
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            
            //Call update Scene Method
            self.updateScene(for: arView)
            self.updatePersistenceAvailability(for: arView)
            self.handlePersistence(for: arView)
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
    }
    
    private func updateScene(for arView: CustomARView) {
        
        // Display focusEntity when the user has selected a model for placement
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        
        // Add model to scene if confirmed for placement
        //        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
        //
        //            // Call place method
        //            self.place(modelEntity, in: arView)
        //            self.placementSettings.confirmedModel = nil
        //        }
        
        if let modelAnchor = self.placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {
            if let anchor = modelAnchor.anchor {
                
                //Anchor is being loaded from persisted scene
                self.place(modelEntity, for: anchor, in: arView)
                
            } else if let transform = getTransformForPlacement(in: arView) {
                
                //Anchor needs to be created for placement
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                self.place(modelEntity, for: anchor, in: arView)
                
                arView.session.add(anchor: anchor)
                
                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
            }
        }
        
    }
    
    
    private func place(_ modelEntity: ModelEntity, for anchor:ARAnchor, in arView: ARView) {
        
        
        // 1. Clone modelEntity. This creates an identical copy of modelEntity and references the same model. This also allows us to have multiple models of the same asset in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2. Enable translation and rotation gestures
        clonedEntity.generateCollisionShapes(recursive: true)
        
        // Enable all Gesture (Scale, Rotation, Translation
        arView.installGestures([.all], for: clonedEntity)
        
        // 3. Create an anchorEntity and ad clonedEntity to the anchorEntity.
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        // 4. Add the anchorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        self.sceneManager.anchorEntities.append(anchorEntity)
        
        print("Added modelEntity to the scene")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any) else {
            
            return nil
        }
        guard let rayCastResult = arView.session.raycast(query).first else { return nil }
        
        return rayCastResult.worldTransform
    }
}


//MARK: -- Persistence

class SceneManager: ObservableObject {
    
    @Published var isPersistenceAvailable: Bool = false
    //Keep tracks of anchorEntities with modelEntities in the AR scene
    @Published var anchorEntities: [AnchorEntity] = []
    
    //Flag to trigger save scene
    var shouldSaveSceneToFileSystem: Bool = false
    var shouldLoadSceneFromFileSystem: Bool = false
    
    
    lazy var persistenceUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("realitykit.persistence")
        } catch {
            
            //fatal Error will crash the app
            fatalError("Unable to get persistenceUrl: \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData: Data? {
        return try? Data(contentsOf: persistenceUrl)
    }
}

extension ARViewContainer {
    
    private func updatePersistenceAvailability(for arView: ARView) {
        
        guard let currentFrame = arView.session.currentFrame else {
            print("ARFrame not available")
            return
        }
        
        switch currentFrame.worldMappingStatus {
                
            case .mapped, .extending:
                self.sceneManager.isPersistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
                
            default:
                self.sceneManager.isPersistenceAvailable = false
                
                
                
        }
    }
    
    private func handlePersistence(for arView: CustomARView) {
        if self.sceneManager.shouldSaveSceneToFileSystem {
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
            
            self.sceneManager.shouldSaveSceneToFileSystem = false
        } else if self.sceneManager.shouldLoadSceneFromFileSystem {
            
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                print("Unable to retrieve data. cancel loadScene operation")
                
                self.sceneManager.shouldLoadSceneFromFileSystem = false
                
                return
            }
            
            self.modelsViewModel.clearModelEntitiesFromMemory()
            
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            
            ScenePersistenceHelper.loadScene(for: arView, at: scenePersistenceData)
            
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            
            self.sceneManager.shouldLoadSceneFromFileSystem = false
        }
    }
}


// MARK: - ARSessionDelegate + Coordinator

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    
                    print("ARSession: did add anchor for modelName: \(modelName)")
                    
                    guard let model = self.parent.modelsViewModel.models.first(where: { $0.name == modelName}) else {
                        print("Unable to retrieve model from modelsViewModel")
                        return
                    }
                    
                    if model.modelEntity == nil {
                        model.asyncLoadModelEntity { completed, error in
                            if completed {
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                                print("Adding modelAnchor with name: \(model.name)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
