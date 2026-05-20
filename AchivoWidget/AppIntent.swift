//
//  AppIntent.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Growth Energy" }
    static var description: IntentDescription {
        "Choose which growth character appears in your widget."
    }
    
    @Parameter(title: "Growth Energy", default: "fiery")
    var growthEnergy: String
}

extension ConfigurationAppIntent {
    
    static var bluey: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.growthEnergy = GrowthEnergy.bluey.rawValue
        return intent
    }
    
    static var greeny: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.growthEnergy = GrowthEnergy.greeny.rawValue
        return intent
    }
    
    static var sunny: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.growthEnergy = GrowthEnergy.sunny.rawValue
        return intent
    }
    
    static var fiery: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.growthEnergy = GrowthEnergy.fiery.rawValue
        return intent
    }
}
