//
//  PlatformResponseMock.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation

final class PlatformResponseMock {
    let fakeSuccessPlatformsResponse: [String: Any] = [
        "data": [
            "count": 2,
            "totalCount": 2,
            "totalPages": 1,
            "page": nil,
            "pageSize": nil,
            "search": "",
            "result": [
                [
                    "name": "Nintendo Switch",
                    "id": "1"
                ],
                [
                    "name": "PlayStation 5",
                    "id": "2"
                ],
                [
                    "name": "PlayStation 4",
                    "id": "3"
                ],
            ]
        ],
        "ok": true,
        "errors": []
    ]
}
