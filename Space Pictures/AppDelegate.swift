//
//  AppDelegate.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataStack = CoreDataStackManager(modelName: "Model")!

    private func initialiseUI() {
        let todayViewController = PictureOfTheDayViewController()
        todayViewController.extendedLayoutIncludesOpaqueBars = true
        todayViewController.navigationItem.largeTitleDisplayMode = .always
        todayViewController.title = "Space Pictures"
        let todayNavigationController = UINavigationController(rootViewController: todayViewController)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = todayNavigationController
        self.window?.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        initialiseUI()
        return true
    }
}

