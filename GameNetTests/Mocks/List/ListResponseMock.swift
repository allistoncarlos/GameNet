//
//  ListResponseMock.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Foundation

final class ListResponseMock {
    let fakeSuccessListsResponse: [String: Any] = [
        "data": [
            "count": 2,
            "totalCount": 2,
            "totalPages": 1,
            "page": nil,
            "pageSize": nil,
            "search": "",
            "result": [
                [
                    "name": "Próximos Jogos",
                    "id": "1"
                ],
                [
                    "name": "Melhores Zeldas",
                    "id": "2"
                ]
            ]
        ],
        "ok": true,
        "errors": []
    ]
}
