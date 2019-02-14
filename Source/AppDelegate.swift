/**
 * Copyright (c) Facebook, Inc. and Microsoft Corporation.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //let window = UIWindow()
        //window.rootViewController = CameraViewController()
        //window.makeKeyAndVisible()

        //self.window = window

        UIApplication.shared.isIdleTimerDisabled = true  // prevent screen dimming and locking

        return true
    }
}

