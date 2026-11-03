import SwiftUI
import WidgetKit

@main
struct BreezeWidgetBundle: WidgetBundle {
    var body: some Widget {
        ConnectedFansWidget()
        BreezeFanWidget()
    }
}
