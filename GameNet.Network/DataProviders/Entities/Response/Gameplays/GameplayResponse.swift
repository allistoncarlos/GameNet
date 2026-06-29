//
//  GameplayResponse.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation

public struct GameplayResponse: Codable {
    public var start: Date
    public var finish: Date?

    enum CodingKeys: String, CodingKey {
        case start
        case finish
    }
    
    public func toGameplay() -> Gameplay {
        return Gameplay(start: self.start, finish: self.finish)
    }
}
