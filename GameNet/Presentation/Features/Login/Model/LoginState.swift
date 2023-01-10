//
//  LoginState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Foundation

enum LoginState: Equatable {
    case idle
    case loading
    case success(Login)
    case error(LoginError)
}
