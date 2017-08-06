//
//  AppDelegate.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/6/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        test()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        
    }
    
    func test(){
        let ref = Database.database().reference(fromURL: "https://demofirebase-e648c.firebaseio.com/")
        let userReference = ref.child("users").child((Auth.auth().currentUser?.uid)!)
        let value = ["online":"false"]
        userReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("Error save db")
                return
            }
            print("Save data successfully")
            //self.dismiss(animated: true, completion: nil)
        })
    }


}

