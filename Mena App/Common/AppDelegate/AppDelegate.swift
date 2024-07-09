//
//  AppDelegate.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/06/2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let shared = AppDelegate()
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

        lazy var context: NSManagedObjectContext = {
            return AppDelegate.persistentContainer.viewContext
        }()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        currentBundle = .main
        window?.rootViewController = Router.setWireFrame()
        window?.becomeKey()
        window?.makeKeyAndVisible()
        applySavedAppearance()
        _ = AppDelegate.persistentContainer
        return true
    }

    func applySavedAppearance() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

}

