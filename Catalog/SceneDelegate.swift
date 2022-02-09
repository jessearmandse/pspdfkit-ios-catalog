//
//  Copyright © 2019-2022 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let windowCoordinator = WindowCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Don't create a new scene for external displays.
        // Use default screen mirroring, and let PSPDFScreenController handle.
        guard session.role == .windowApplication,
              let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let catalog = windowCoordinator.installCatalogStack(in: window)

        // iOS 13 doesn't pick up the accent color from the asset catalog, so
        // we apply a tint color manually here.
        if #available(iOS 14, *) {} else {
            window.tintColor = UIColor.catalogAccent
            // The accessory view lives on the keyboard window, so it doesn't auto inherit the window tint color
            FreeTextAccessoryView.appearance().tintColor = UIColor.catalogAccent
        }

        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            if userActivity.isOpenExampleActivity {
                catalog.restoreUserActivityState(userActivity)
            } else if userActivity.isOpenDocumentActivity {
                if let fileURL = userActivity.fileURL {
                    NotificationCenter.default.post(name: .PSCDocumentOpenedInNewScene, object: nil, userInfo: ["documentURL": fileURL])
                    windowCoordinator.openTabbedControllerForDocument(at: fileURL)
                }
            }
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            windowCoordinator.handleOpenURL(urlContext.url)
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let success = windowCoordinator.openShortcutItem(shortcutItem)
        completionHandler(success)
    }
}

extension NSNotification.Name {
    public static let PSCDocumentOpenedInNewScene = NSNotification.Name("PSCDocumentOpenedInNewScene")
}
