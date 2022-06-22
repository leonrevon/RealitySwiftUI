//
//  BrowseView.swift
//  RealityUIKit
//
//  Created by Leon Teng on 10.06.22.
//

import SwiftUI

struct BrowseView: View {
   
    @Binding var isBrowseVisible: Bool
    var body: some View {
        
        NavigationView {
            
            ScrollView(showsIndicators: false) {
                //GridViews for thumbnails
                RecentsGrid(isBrowseVisible: $isBrowseVisible)
                ModelsByCategoryGrid(isBrowseVisible: $isBrowseVisible)
            }
            
            .navigationBarTitle(Text("Browse"), displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.isBrowseVisible.toggle()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct RecentsGrid: View {
    @EnvironmentObject var placementSetting: PlacementSettings
    @Binding var isBrowseVisible: Bool
    var body: some View {
        if !self.placementSetting.recentlyPlaced.isEmpty {
            HorizontalGrid(isBrowseVisible: $isBrowseVisible, title: "Recents", items: getRecentsUniqueOrdered())
        }
    }
    
    func getRecentsUniqueOrdered() -> [Model] {
        var recentsUniqueOrderedArray: [Model] = []
        var modelNameSet: Set<String> = []
        
        for model in self.placementSetting.recentlyPlaced.reversed() {
            if !modelNameSet.contains(model.name) {
                recentsUniqueOrderedArray.append(model)
                modelNameSet.insert(model.name)
            }
        }
        
        return recentsUniqueOrderedArray
    }
}

struct ModelsByCategoryGrid: View {
    @Binding var isBrowseVisible: Bool
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    
//    let models = Models()
    
    var body: some View{
        VStack{
            ForEach(ModelCategory.allCases, id: \.self) { category in
                
//                if let modelsByCategory = models.get(category: category) {
                if let modelsByCategory = self.modelsViewModel.models.filter({ $0.category == category}) {
                    HorizontalGrid(isBrowseVisible: $isBrowseVisible, title: category.label, items: modelsByCategory)
                }
            }
        }
       
    }
}


struct HorizontalGrid: View{
    
    @EnvironmentObject var placementSetting: PlacementSettings
    @Binding var isBrowseVisible: Bool
    var title: String
    var items: [Model]
    // let each item has a fix height of 150 px
    private let gridItemLayout = [GridItem(.fixed(150))]
    
    var body: some View {
        VStack (alignment: .leading){
            
            Separator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                                  
                    LazyHGrid(rows: gridItemLayout, spacing:20) {
                        
                        //Place Holder for items in grid
                        ForEach(0..<items.count, id:\.self) { index in
                            
                            let model = items[index]
                            ItemButton(model: model) {
                                // call model method to async load modelEntity
                                model.asyncLoadModelEntity { completed, error in
                                    if completed {
                                        self.placementSetting.selectedModel = model
                                    }
                                }
                                // select model for placement
                                self.placementSetting.selectedModel = model 
                                print("BrowseView: selected \(model.name)")
                                self.isBrowseVisible = false
                            }
//                            Color(UIColor.secondarySystemFill)
//                                .frame(width: 150, height: 150)
//                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
            }
        }
    }
}

struct ItemButton: View {
    @ObservedObject var model: Model
    let action: () -> Void
    
    var body: some View {
        
        Button(action: {
            self.action()
        }) {
            Image(uiImage: self.model.thumbnail)
                .resizable()
                .frame(height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(8.0)
        }
        
    }
}


// To Add line between Grids
struct Separator: View {
    
    var body: some View {
        Divider()
        //Left and Right padding of the divider Line
            .padding(.horizontal, 20)
        //Top and Bottom padding of the divider Line
            .padding(.vertical, 10)
    }
}
