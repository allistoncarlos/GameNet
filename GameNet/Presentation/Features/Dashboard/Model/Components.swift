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
    
    case spacer = "Spacer"
    
    case vstack = "VStack"
    case scrollView = "ScrollView"
    case hstack = "HStack"
    
    case navigationLink = "NavigationLink"
    
    case text = "Text"
    case dashboardText = "DashboardText"
    case subtitle = "Subtitle"
    
    case image = "Image"
    case card = "Card"
    
    case carousel = "Carousel"
    case carouselCover = "CarouselCover"
}
