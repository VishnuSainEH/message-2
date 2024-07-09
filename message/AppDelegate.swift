//
//  AppDelegate.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import Firebase
import FirebaseAuth // Include FirebaseAuth for Firebase authentication

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? // Declare window property

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        
        // Update status bar style for iOS 13 and later
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = .black
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        let font = UIFont(name: "OpenSans", size: 18)
        if let font = font {
            // Corrected attribute names and syntax
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: font
            ]
        }
        
        FirebaseApp.configure()
        login() // Call login method to check current user
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func login() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let naviVC = storyboard.instantiateViewController(withIdentifier: "RoomVC") as! UINavigationController // Corrected instantiateViewControllerWithIdentifier to instantiateViewController(withIdentifier:)
            window?.rootViewController = naviVC
        }
    }

