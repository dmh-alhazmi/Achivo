//
//  AchivoWidgetLiveActivity.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AchivoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AchivoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AchivoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AchivoWidgetAttributes {
    fileprivate static var preview: AchivoWidgetAttributes {
        AchivoWidgetAttributes(name: "World")
    }
}

extension AchivoWidgetAttributes.ContentState {
    fileprivate static var smiley: AchivoWidgetAttributes.ContentState {
        AchivoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AchivoWidgetAttributes.ContentState {
         AchivoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AchivoWidgetAttributes.preview) {
   AchivoWidgetLiveActivity()
} contentStates: {
    AchivoWidgetAttributes.ContentState.smiley
    AchivoWidgetAttributes.ContentState.starEyes
}
