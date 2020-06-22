//
//  AppDelegate.swift
//  ABC Recorder
//
//  Created by Rocky Wei on 2020-06-20.
//  Copyright © 2020 Treefrog Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UILabel.appearance().textColor = .darkblue
		UITextField.appearance().textColor = .darkblue
		UIBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkblue], for: .normal)
		UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkblue], for: .normal)
		UINavigationBar.appearance().tintColor = .darkblue
		return true
	}
}

