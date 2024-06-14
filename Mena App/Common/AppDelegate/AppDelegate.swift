//
//  AppDelegate.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/06/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let shared = AppDelegate()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        currentBundle = .main
        window?.rootViewController = Router.setWireFrame()
        window?.becomeKey()
        window?.makeKeyAndVisible()
        applySavedAppearance()
        
        return true
    }

    func applySavedAppearance() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

}

