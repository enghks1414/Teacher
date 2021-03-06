//
//  AppDelegate.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import Firebase
import TouchVisualizer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    
    var window: UIWindow?
    var curCategory = tc_category[0]
    var orientationLock = UIInterfaceOrientationMask.all

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Touch Visiable
        //Visualizer.start()
        
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (FIRAuth.auth()?.currentUser) != nil {
            let uid = (FIRAuth.auth()?.currentUser?.uid)! as String
            let ref = FIRDatabase.database().reference().child("Users").child(uid)
            let name = (FIRAuth.auth()?.currentUser?.displayName)! as String
            
            let url = String( describing: (FIRAuth.auth()?.currentUser?.photoURL)!)
            let value : Dictionary = ["name" : name, "profileImg":url]
            ref.updateChildValues(value)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabView")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()

        }else{
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "auth_vc") as! TcAuthViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            //performSegue(withIdentifier: "auth_segue", sender: nil)
        }
        UITabBar.appearance().tintColor = UIColor(red: 0.37, green: 0.21, blue: 0.69, alpha: 1)
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.37, green: 0.21, blue: 0.69, alpha: 1)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //화면 회전 잠금
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
}

