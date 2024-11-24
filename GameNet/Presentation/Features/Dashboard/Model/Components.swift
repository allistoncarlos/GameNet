//
//  Components.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/11/24.
//

import Foundation

// TODO: Melhorar essa parte com CustomStringConvertible
enum Components: String, CaseIterable, Identifiable, CustomStringConvertible {
    var id : String { UUID().uuidString }
    
    var description: String { rawValue }
    
    case vstack = "VStack"
    case scrollView = "ScrollView"
    
    case text = "Text"
    case image = "Image"
}
