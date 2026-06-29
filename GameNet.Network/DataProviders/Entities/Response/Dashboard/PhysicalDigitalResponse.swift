//
//  PhysicalDigitalResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct PhysicalDigitalResponse: Codable {
    public var physical: Int
    public var digital: Int
    
    enum CodingKeys: String, CodingKey {
        case physical
        case digital
    }
    
    public func toPhysicalDigital() -> PhysicalDigital {
        return PhysicalDigital(physical: self.physical, digital: self.digital)
    }
}
