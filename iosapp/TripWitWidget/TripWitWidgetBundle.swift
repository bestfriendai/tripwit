import WidgetKit
import SwiftUI

@main
struct TripWitWidgetBundle: WidgetBundle {
    var body: some Widget {
        TripWitWidget()
        if #available(iOSApplicationExtension 16.2, *) {
            TripWitLiveActivity()
        }
        if #available(iOSApplicationExtension 18.0, *) {
            TripWitControl()
            TripWitMarkStopControl()
        }
    }
}
