//
//  Model.swift
//  RealityUIKit
//
//  Created by Leon Teng on 13.06.22.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: String, CaseIterable {
    case cup
    case instrument
    case food
    
    var label: String {
        get {
            switch self {
                case .cup:
                    return "Cup"
                    
                case .instrument:
                    return "Instrument"
                    
                case .food:
                    return "Food"
            }
        }
    }
}

class Model: ObservableObject, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var category: ModelCategory
    @Published var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation

        FirebaseStorageHelper.asyncDownloadToFilesystem(relativePath: "thumbnails/\(self.name).png") { localUrl in
            do {
                let imageData = try Data(contentsOf: localUrl)
                self.thumbnail = UIImage(data:imageData) ?? self.thumbnail
            } catch {
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    //Load async model
    func asyncLoadModelEntity(handler: @escaping (_ completed: Bool, _ error: Error?) -> Void) {
//        let filename = self.name + ".usdz"
//        self.cancellable = ModelEntity.loadModelAsync(named: filename)
        FirebaseStorageHelper.asyncDownloadToFilesystem(relativePath: "models/\(self.name).usdz") { localUrl in
            self.cancellable = ModelEntity.loadModelAsync(contentsOf: localUrl)
                .sink { loadCompletion in
                    switch loadCompletion {
                        case .failure(let error): print ("Unable to load modelEntity for \(self.name). Error: \(error.localizedDescription)")
                            handler(false, error)
                        case .finished:
                            break
                    }
                } receiveValue: { modelEntity in
                    self.modelEntity = modelEntity
                    self.modelEntity?.scale *= self.scaleCompensation
                    
                    handler(true, nil)
                    print("modelEntity for \(self.name) has been loaded")
                }
        }
       

    }
}
//references of all the models
//struct Models {
//    var all: [Model] = []
//    
//    init() {
//        // Cup
//        let cofeeCup = Model(name: "cup", category: .cup, scaleCompensation: 1)
//        self.all += [cofeeCup]
//        
//        //Instrument
//        let guitar = Model(name: "guitar", category: .instrument, scaleCompensation: 1)
//        self.all += [guitar]
//        
//        //Food
//        let cake = Model(name: "lemon", category: .food, scaleCompensation: 1)
//        self.all += [cake]
//        
//    }
//    
//    func get(category: ModelCategory) -> [Model] {
//        return all.filter( {$0.category == category} )
//    }
//}

