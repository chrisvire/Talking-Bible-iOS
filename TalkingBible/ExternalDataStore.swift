/*

Copyright (C) 2014 Apple Inc. All Rights Reserved.

See LICENSE.txt for this sample’s licensing information



Abstract:



Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, and for convenience the managed object model and URL for the persistent store and application documents directory.



*/



import Foundation
import CoreData

final class ExternalDataStore {
    
    init() {
        if NSFileManager.defaultManager().fileExistsAtPath(self.storeURL.path!) == false {
            logInfo("External data store doesn't already exist")
            if let preloadPath = NSBundle.mainBundle().pathForResource("TalkingBibleData", ofType: "sqlite") {
                logInfo("Found preloaded external data store")
                if let preloadURL = NSURL.fileURLWithPath(preloadPath) {
                    logInfo("Copying preloaded external data store to store URL")
                    
                    var copyError: NSError?
                    NSFileManager.defaultManager().copyItemAtURL(preloadURL, toURL: self.storeURL, error: &copyError)
                    
                    if let copyError = copyError {
                        logError(copyError.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: Properties
    
    class var sharedManager: ExternalDataStore {
        struct Singleton {
            static let coreDataStackManager = ExternalDataStore()
        }
        
        return Singleton.coreDataStackManager
    }
    
    /// The managed object model for the application.
    lazy var modelURL: NSURL = {
        return NSBundle.mainBundle().URLForResource(Config.externalData.mainModelName, withExtension: "momd")!
    }()
    
    /// URL for the main Core Data store files
    lazy var storeURL: NSURL = {
        let applicationSupportDirectory = NSURL(fileURLWithPath: NSFileManager.defaultManager().findOrCreateDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appendPathComponent: Config.externalData.applicationDocumentsDirectoryName, error: nil), isDirectory: true)
        return NSURL(string: Config.externalData.mainStoreFileName, relativeToURL: applicationSupportDirectory)!
    }()
    
    /// Primary persistent store coordinator for the application.
    var _persistentStoreCoordinator: MDMPersistenceController?
    var persistentStoreCoordinator: MDMPersistenceController {
        // This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
        
        if _persistentStoreCoordinator == nil {
            _persistentStoreCoordinator = MDMPersistenceController(storeURL: self.storeURL, modelURL: self.modelURL)
        }
        
        return _persistentStoreCoordinator!
    }
    
    /// The directory the application uses to store the Core Data store file.
    lazy var applicationDocumentsDirectory: NSURL? = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        var applicationSupportDirectory = urls[urls.count - 1] as! NSURL
        
        applicationSupportDirectory = applicationSupportDirectory.URLByAppendingPathComponent(Config.externalData.applicationDocumentsDirectoryName)
        
        var error: NSError?
        
        if let properties = applicationSupportDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error) {
            if let isDirectory = properties[NSURLIsDirectoryKey] as? NSNumber {
                if !isDirectory.boolValue {
                    let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize applicationSupportDirectory")
                    
                    let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize applicationSupportDirectory")
                    
                    let userInfo = [
                        NSLocalizedDescriptionKey: description,
                        NSLocalizedFailureReasonErrorKey: reason
                    ]
                    
                    error = NSError(domain: Config.externalData.errorDomain, code: 101, userInfo: userInfo)
                    
                    fatalError("Could not access the application data folder.")
                    
                    //                    NSApplication.sharedApplication().presentError(error!)
                }
            }
        }
            
        else {
            if error != nil && error!.code == NSFileReadNoSuchFileError {
                let ok = fileManager.createDirectoryAtPath(applicationSupportDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
                
                if !ok {
                    //                    NSApplication.sharedApplication().presentError(error!)
                    
                    fatalError("Could not create the application data folder.")
                }
            }
        }
        
        return applicationSupportDirectory
    }()
    
    // Replacing the store
    func resetCoreData() {
        logInfo("Reseting managed object context")
        var context: NSManagedObjectContext = self.persistentStoreCoordinator.managedObjectContext
        context.reset()
        
        logInfo("Nil'ing persistent store coordinator")
        _persistentStoreCoordinator = nil        
    }
}