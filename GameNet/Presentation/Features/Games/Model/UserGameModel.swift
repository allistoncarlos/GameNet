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

    func toGameData(cover: Data) -> Game? {
        if let platform,
           let platformId = platform.id {
            return Game(
                id: nil,
                name: name,
                cover: cover,
                coverURL: nil,
                platformId: platformId,
                platform: platform.name
            )
        }

        return nil
    }

    func toUserGameData() -> UserGame? {
        /*
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency

         if let number = formatter.number(from: str) {
             let amount = number.decimalValue
             print(amount)
         }
         */

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let number = formatter.number(from: price) {
            return UserGame(
                id: nil,
                gameId: "",
                userId: "",
                price: number.doubleValue,
                boughtDate: boughtDate,
                have: have,
                want: false,
                digital: digital,
                original: original
            )
        }

        return nil
    }
}
