//
//  Settings.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/29/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import Foundation

struct Settings {

    enum Style {
        case stepper, sw, expand
    }
    
    var style: Style
    var title: String
    var units: String
    var hidden = false
    var getValue: () -> Double
    var setValue: (Double) -> Void
}
