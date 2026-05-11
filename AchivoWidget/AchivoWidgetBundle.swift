//
//  AchivoWidgetBundle.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import WidgetKit
import SwiftUI

@main
struct AchivoWidgetBundle: WidgetBundle {
    var body: some Widget {
        AchivoWidget()
       // AchivoWidgetControl()
        AchivoWidgetLiveActivity()
    }
}
