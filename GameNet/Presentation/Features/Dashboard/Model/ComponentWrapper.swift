//
//  ComponentWrapper.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//

import Foundation

struct Element: Decodable, Identifiable {
    let id: String?
    let componentType: String?
    let properties: Properties?
    let elements: [Element]?

    enum CodingKeys: String, CodingKey {
        case id
        case componentType
        case properties
        case elements
    }

    init(
        id: String? = nil,
        componentType: String? = nil,
        properties: Properties? = nil,
        elements: [Element]? = nil
    ) {
        self.id = id
        self.componentType = componentType
        self.properties = properties
        self.elements = elements
    }
}

struct Properties: Decodable, Identifiable {
    let id: String?
    let componentType: String?
    let title: String?
    let color: String?
    let value: String?
    let url: String?
    let spacing: CGFloat?

    enum CodingKeys: String, CodingKey {
        case id
        case componentType
        case title
        case color
        case value
        case url
        case spacing
    }

    init(
        id: String? = nil,
        componentType: String? = nil,
        title: String? = nil,
        color: String? = nil,
        value: String? = nil,
        url: String? = nil,
        spacing: CGFloat? = nil
    ) {
        self.id = id
        self.componentType = componentType
        self.title = title
        self.color = color
        self.value = value
        self.url = url
        self.spacing = spacing
    }
}
