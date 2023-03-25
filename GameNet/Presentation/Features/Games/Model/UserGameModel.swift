//
//  UserGameModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/03/23.
//

import Foundation
import GameNet_Network

public class UserGameModel: ObservableObject {
    public var name: String = ""
    public var platform: Platform?
    public var price: Double?
    public var boughtDate: Date = .init()
    public var have: Bool = true
    public var digital: Bool = false
    public var original: Bool = true
}
