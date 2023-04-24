//
//  Binding+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/03/23.
//

import SwiftUI

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value>, deselectTo value: Value) {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 == source.wrappedValue ? value : $0 }
        )
    }
}
