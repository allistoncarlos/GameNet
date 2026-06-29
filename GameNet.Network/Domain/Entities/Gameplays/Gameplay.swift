//
//  Gameplay.swift
//
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation
import SwiftData

@Model
public class Gameplay: Equatable, Hashable {

    // MARK: Lifecycle

    public init(start: Date, finish: Date?) {
        self.start = start
        self.finish = finish
    }

    // MARK: Public

    public var start: Date
    public var finish: Date?
}
