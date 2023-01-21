//
//  HomeConnectivityState.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 21/01/23.
//

import Foundation

enum HomeConnectivityState: Equatable {
    case idle
    case askingForCredentials
    case notLogged
    case logged
}
