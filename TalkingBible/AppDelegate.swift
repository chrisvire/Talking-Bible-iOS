//
//  Copyright 2015 Talking Bibles International
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import CoreData
import AVFoundation
import QuartzCore

//TODO clean up player statemachine moving side effects from shouldTransititionFrom to didTransitionFrom.
//     can't be too hasty to do this because it probably will break hidden race conditions.
//TODO accessability labels on interface elements (probably mostly done)
//TODO fix deep link urls, going directly to view controller and skipping default user
//TODO alternatively, remove deep link urls because it will be a hassle to maintain these
//TODO replace deprecated searchDisplayController
//TODO explore possibility of removing downloading/replacing CoreData now that private URLs are off the table
//TODO add tests 😔

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dashboardController: UIViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {        
        // Check if main store exists
        let bundleVersion = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        let appFirstStartOfVersionKey = "first_start_\(bundleVersion)"
        
        let alreadyStartedOnVersion: Bool? = NSUserDefaults.standardUserDefaults().boolForKey(appFirstStartOfVersionKey)
        if alreadyStartedOnVersion == nil || alreadyStartedOnVersion == false {
            self.firstStart()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: appFirstStartOfVersionKey)
        }
        
        // Select audio session singleton
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil)

        // Remote notifications
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        // Parse
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Config.parse.applicationId, clientKey: Config.parse.clientKey)
        
        // Stripe
//        Stripe.setDefaultPublishableKey(Config.stripe.publishableKey)
        
        // Branch (deep links)
        let branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions, andRegisterDeepLinkHandler: DeepLinks.branchHandler)
        
        // Analytics
        GAI.sharedInstance().trackUncaughtExceptions = false
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = GAILogLevel.Warning
        GAI.sharedInstance().trackerWithTrackingId(Config.analytics.googleAnalyticsId)

        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
        
        #if DEBUG_VERSION
        logInfo("Filtering Google Analytics for debugging")
        GAI.sharedInstance().defaultTracker.set(GAIFields.customDimensionForIndex(3), value: "Debug")
        #else
        logInfo("Filtering Google Analytics for release")
        GAI.sharedInstance().defaultTracker.set(GAIFields.customDimensionForIndex(3), value: "Release")
        #endif
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        DefaultUser.sharedManager.save()
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        DefaultUser.sharedManager.save()
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        DefaultUser.sharedManager.save()
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Remote downloading
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { success, error in
            if success == false {
                logError("Could not save current installation to parse: \(error!.localizedDescription)")
                return
            }
            
            PFPush.subscribeToChannelInBackground(Config.parse.channels.coreDataUpdates) { success, error in
                if success == false{
                    logError("Could not subscribe to core data updates: \(error!.localizedDescription)")
                }
            }

            PFPush.subscribeToChannelInBackground(Config.parse.channels.articleUpdates) { success, error in
                if success == false{
                    logError("Could not subscribe to article updates: \(error!.localizedDescription)")
                }
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        logError("Failed to register with error: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        switch userInfo["channel"] as? String {
        case .Some(Config.parse.channels.coreDataUpdates):
            if let newDatabaseArchive = userInfo["dbArchive"] as? String {
                logInfo("Received link to new database archive at \(newDatabaseArchive)")
                Downloader.sharedManager.start(newDatabaseArchive)
                completionHandler(UIBackgroundFetchResult.NoData)
            }
        case .Some(Config.parse.channels.articleUpdates):
            KnowledgeBase.sharedManager.fetchKBArticles({ _ in
                completionHandler(UIBackgroundFetchResult.NewData)
            }, failure: { error in
                logError("Could not update articles: \(error?.localizedDescription)")
                completionHandler(UIBackgroundFetchResult.Failed)
            }, usingLocalDatastore: false)
        default:
            break
        }
    }
    
    // Deep-links
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if Branch.getInstance().handleDeepLink(url) {
            return true
        }
        
        return DeepLinks.handleDeepLink(url)
    }
    
    // First start
    func firstStart() {
        // Destroy existing main store
        let applicationSupportDirectory = NSURL(fileURLWithPath: NSFileManager.defaultManager().findOrCreateDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appendPathComponent: Config.externalData.applicationDocumentsDirectoryName, error: nil), isDirectory: true)
        let storeURL = NSURL(string: Config.externalData.mainStoreFileName, relativeToURL: applicationSupportDirectory)!
        if NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!) == true {
            logInfo("External data store already exists")
            
            var removeError: NSError?
            NSFileManager.defaultManager().removeItemAtURL(storeURL, error: &removeError)
            
            if let removeError = removeError {
                logError(removeError.localizedDescription)
            }
        }
    }
}

