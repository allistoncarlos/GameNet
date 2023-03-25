//
//  UserGameModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/03/23.
//

import Foundation
import GameNet_Network

struct UserGameModel {
    var name: String = ""
    var platform: Platform?
    var price: String = ""
    var boughtDate: Date = .init()
    var have: Bool = true
    var digital: Bool = false
    var original: Bool = true
}
