import Foundation
import WidgetKit

struct ConnectedFansEntry: TimelineEntry {
    let date: Date
    let fans: [ConnectedFanSnapshot]
    var showLighting = true
    var showTimer = true
}
