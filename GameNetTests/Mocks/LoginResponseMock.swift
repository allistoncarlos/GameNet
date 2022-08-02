//
//  LoginResponseMock.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Foundation

final class LoginResponseMock {
    let fakeSuccessLoginResponse: [String: Any] = [
        "id": "123",
        "username": "user",
        "firstName": "First",
        "lastName": "Name",
        "access_token": "accessToken123",
        "refresh_token": "RefreshToken123",
        "expires_in": "2022-04-09T19:57:56Z"
    ]

    let fakeFailureLoginResponse: [String: Any] = [
        "message": "Username or password is incorrect"
    ]
}
