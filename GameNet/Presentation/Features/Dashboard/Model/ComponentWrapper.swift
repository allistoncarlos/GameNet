//
//  ComponentWrapper.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//


import Foundation

struct Element: Decodable {
    let value: String?
    let title: String?
    let color: String?
    let url: String?
    
    let elements: [String: Element]?
    
    init(
        value: String? = nil,
        title: String? = nil,
        color: String? = nil,
        url: String? = nil,
        elements: [String : Element]? = nil
    ) {
        self.value = value
        self.title = title
        self.color = color
        self.url = url
        self.elements = elements
    }
}

// Estrutura dinâmica para o JSON
struct DynamicContainer: Decodable {
    let elements: [String: [String: Element]]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        var tempElements: [String: [String: Element]] = [:]
        
        for key in container.allKeys {
            let nestedContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
            var childElements: [String: Element] = [:]
            
            for nestedKey in nestedContainer.allKeys {
                let element = try nestedContainer.decode(Element.self, forKey: nestedKey)
                childElements[nestedKey.stringValue] = element
            }
            tempElements[key.stringValue] = childElements
        }
        elements = tempElements
    }
}

// Chave dinâmica para lidar com nomes de propriedades desconhecidos
struct DynamicKey: CodingKey {
    let stringValue: String
    var intValue: Int? { return nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
