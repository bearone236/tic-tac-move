import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct TicTacMoveApp: App {
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    requestTrackingIfNeeded()
                }
        }
    }

    private func requestTrackingIfNeeded() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in
            AdManager.shared.loadAd()
        }
    }
}
