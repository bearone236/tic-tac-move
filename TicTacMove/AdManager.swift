import GoogleMobileAds
import UIKit

/// Loads and shows an AdMob interstitial between rounds.
///
/// ⚠️ Requires the Google-Mobile-Ads-SDK Swift package to be added to this
/// Xcode project first (File > Add Package Dependencies…, URL:
/// https://github.com/googleads/swift-package-manager-google-mobile-ads.git).
///
/// The ad unit ID below is Google's public **test** interstitial ID — it
/// always serves a test ad and is safe to ship during development, but it
/// must be replaced with a real ad unit ID from your own AdMob account
/// before submitting to the App Store. Same for the GADApplicationIdentifier
/// in the project's build settings.
final class AdManager: NSObject {
    static let shared = AdManager()

    // TODO: replace with your own AdMob interstitial ad unit ID before release.
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var interstitial: InterstitialAd?
    private var onDismiss: (() -> Void)?

    private override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        InterstitialAd.load(with: adUnitID, request: Request()) { [weak self] ad, _ in
            guard let self else { return }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }

    /// Shows the interstitial if one is ready; otherwise calls `onDismiss`
    /// immediately so gameplay is never blocked by ad availability.
    func showAd(onDismiss: @escaping () -> Void) {
        guard let interstitial, let root = Self.topViewController() else {
            onDismiss()
            loadAd()
            return
        }
        self.onDismiss = onDismiss
        interstitial.present(from: root)
    }

    private static func topViewController() -> UIViewController? {
        guard
            let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadAd()
        onDismiss?()
        onDismiss = nil
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadAd()
        onDismiss?()
        onDismiss = nil
    }
}
