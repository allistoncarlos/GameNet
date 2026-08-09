//
//  UserGameGameplayRequest.swift
//  GameNet
//

import Foundation

struct UserGameGameplayStartRequest: Encodable {
    let start: Date
}

struct UserGameGameplayFinishRequest: Encodable {
    let finish: Date
}
