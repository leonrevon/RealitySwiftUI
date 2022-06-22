//
//  View+Extension.swift
//  RealityUIKit
//
//  Created by Leon Teng on 15.06.22.
//

import SwiftUI

extension View {
    
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
            case true: self.hidden()
            case false: self
        }
    }
}
