//
//  PhysicalDigital.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class PhysicalDigital: Equatable, Hashable {

    // MARK: Lifecycle

    public init(physical: Int, digital: Int) {
        self.physical = physical
        self.digital = digital
    }

    // MARK: Public

    public var physical: Int
    public var digital: Int

}
