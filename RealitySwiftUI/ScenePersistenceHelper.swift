//
//  ScenePersistenceHelper.swift
//  RealityUIKit
//
//  Created by Leon Teng on 15.06.22.
//

import RealityKit
import Foundation
import ARKit


class ScenePersistenceHelper {
    
    class func saveScene(for arView: CustomARView, at persistenceUrl: URL) {
        
        print("save scene to local filesystem")
        
        // 1. Get Current worldMap from arView.session
        arView.session.getCurrentWorldMap { worldMap, error in

            
            // 2. Safely unwrap WorldMap
            guard let map = worldMap else {
                print(error!.localizedDescription)
                
                //Maybe can add alert to show user here!
                return
            }
        
            // 3. Archive data and write to filesystem
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                try sceneData.write(to: persistenceUrl, options: [.atomic])
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    class func loadScene(for arView: CustomARView, at scenePersistenceData: Data) {
        print("Load scene from local filesystem")
        
        // 1. Unarchive the scenePersistenceData and retrieve ARWorldMap
        
        let worldMap: ARWorldMap = {
           
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    fatalError("Persistence Error: No ARWOrldMap in archive")
                }
                
                return worldMap
            } catch {
                fatalError("Unable to unarchive ARWorldMap from scenePersistenceURL")
            }
        }()
        
        let newConfig = arView.defaultConfiguration
        newConfig.initialWorldMap = worldMap
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
        
}
