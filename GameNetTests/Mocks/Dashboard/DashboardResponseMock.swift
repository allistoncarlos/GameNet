//
//  DashboardResponseMock.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation

final class DashboardResponseMock {
    let fakeSuccessDashboardResponse: [String: Any] = [
        "data": [
            "boughtByYear": [
                [
                    "year": 2022,
                    "total": 200.33,
                    "quantity": 7
                ]
            ],
            "finishedByYear": [
                [
                    "year": 2022,
                    "total": 3
                ]
            ],
            "playingGames": [
                [
                    "name": "The Legend of Zelda: Breath of the Wild",
                    "platform": "Nintendo Switch",
                    "coverURL": "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    "latestGameplaySession": [
                        "userId": "123",
                        "userGameId": "123",
                        "start": "2021-01-22T17:30:46Z",
                        "finish": "2021-01-22T18:20:33Z",
                        "id": "123"
                    ],
                    "id": "123"
                ]
            ],
            "physicalDigital": [
                "physical": 111,
                "digital": 271
            ],
            "gamesByPlatform": [
                "total": 382,
                "platforms": [
                    [
                        "platformId": "123",
                        "platformName": "PlayStation 4",
                        "platformGamesTotal": 83
                    ]
                ]
            ],
            "totalPrice": 9153.87,
            "totalGames": 486,
            "id": nil
        ],
        "ok": true,
        "errors": []
    ]
}
