//
//  SessionSettings.swift
//  RealityUIKit
//
//  Created by Leon Teng on 15.06.22.
//

import SwiftUI

class SessionSettings: ObservableObject {
    
    @Published var isPeopleOcclusionEnable: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
}
