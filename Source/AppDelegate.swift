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

// Screenshot function 1
extension UIApplication {
    var screenShot: UIImage? {
        return keyWindow?.layer.screenShot
    }
}

// Screenshot function 2
extension CALayer {
    var screenShot: UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
