//
//  ModelsViewModel.swift
//  RealityUIKit
//
//  Created by Leon Teng on 16.06.22.
//

import Foundation
import FirebaseFirestore

class ModelsViewModel: ObservableObject {
    @Published var models: [Model] = []
    
    private let db = Firestore.firestore()
    
    
    func fetchData() {
        db.collection("models").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                
                print("Firestore: No documents")
                return
            }
            
            self.models = documents.map { (querydocumentSnapshot) -> Model in
                let data = querydocumentSnapshot.data()
                
                let name = data["name"] as? String ?? ""
                let categoryText = data["category"] as? String ?? ""
                let category = ModelCategory(rawValue: categoryText) ?? .cup
                let scaleCompensation = data["scaleCompensation"] as? Double ?? 1.0
                
                return Model(name: name, category: category, scaleCompensation: Float(scaleCompensation))
            }
        }
    }
    
    func clearModelEntitiesFromMemory() {
        for model in models {
            model.modelEntity = nil
        }
    }
}
