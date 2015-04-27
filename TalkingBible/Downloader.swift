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

import Foundation

final class Downloader: NSObject, NSURLSessionDownloadDelegate {
    typealias CompletionHandlerType = () -> Void
    
    var completionHandlerDictionary: [NSString: CompletionHandlerType] = [:]
    
    var backgroundURLSession: NSURLSession?
    var applicationSupportDirectory: NSURL?
    
    class var sharedManager: Downloader {
        struct Singleton {
            static let downloader = Downloader()
        }
        
        return Singleton.downloader
    }
    
    override init() {
        super.init()
        
        self.applicationSupportDirectory = NSURL(fileURLWithPath: NSFileManager.defaultManager().findOrCreateDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appendPathComponent: Config.externalData.applicationDocumentsDirectoryName, error: nil), isDirectory: true)
        
        struct Static {
            static var backgroundURLSession: NSURLSession?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(Config.backgroundSession.downloadIdentifier)
            Static.backgroundURLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        }
        
        self.backgroundURLSession = Static.backgroundURLSession
    }
    
    func start(dataArchive: String) {
        let downloadURL = NSURL(string: dataArchive)!
        
        logInfo("Starting background download of \(downloadURL.absoluteString)")
        
        let request = NSURLRequest(URL: downloadURL)
        if let task = self.backgroundURLSession?.downloadTaskWithRequest(request) {
            task.taskDescription = NSString(string: "data archive") as String
            task.resume()
            return
        }
        
        ExternalDataStore.sharedManager.resetCoreData()
    }

    //MARK: - NSURLSessionDownload
    
    //Tells the delegate that the download task has resumed downloading
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    //Periodically informs the delegate about the download’s progress
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        logInfo("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
    }
    
    //Tells the delegate that a download task has finished downloading
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        logInfo("Did finish downloading \(downloadTask.taskDescription) to \(location)")
        
        let newLocation = NSURL(string: Config.externalData.localArchiveName, relativeToURL: applicationSupportDirectory)!
        
        logInfo("Moving \(downloadTask.taskDescription) to \(newLocation)")
        
        NSFileManager.defaultManager().removeItemAtURL(newLocation, error: nil)
        
        var copyError: NSError?
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: newLocation, error: &copyError)
        
        if let copyError = copyError {
            logError(copyError.localizedDescription)
        }
        
        let ssZipArchive = SSZipArchive()
        var unzipped = SSZipArchive.unzipFileAtPath(newLocation.path, toDestination: applicationSupportDirectory?.path, delegate: self)
        
        if unzipped == true {
            var deleteError: NSError?
            NSFileManager.defaultManager().removeItemAtURL(newLocation, error: &deleteError)
            
            if let deleteError = deleteError {
                logError(deleteError.localizedDescription)
            }
        }
    }
    
    // Called after NSURLSession delegate messages are sent
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        callCompletionHandlerForSession(session.configuration.identifier)
    }
    
    //Works for application:handleEventsForBackgroundURLSession
    func handleEventsForBackgroundURLSession(identifier: String, completionHandler: CompletionHandlerType) {
        let session = self.backgroundURLSession
        
        addCompletionHandler(completionHandler, forSession: identifier)
    }
    
    func addCompletionHandler(handler: CompletionHandlerType, forSession identifier: NSString) {
        completionHandlerDictionary[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: NSString) {
        if let handler = completionHandlerDictionary[identifier] {
            completionHandlerDictionary[identifier] = nil
            handler()
        }
    }
    
    // Finish up
    func completeDownload() {
        ExternalDataStore.sharedManager.resetCoreData()
    }
}

extension Downloader: SSZipArchiveDelegate {
    func zipArchiveProgressEvent(loaded: Int, total: Int) {
        logInfo("zipArchiveProgressEvent: loaded: \(loaded) total: \(total)")
        
        if loaded == total {
            completeDownload()
        }
    }
}