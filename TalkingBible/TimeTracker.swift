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
import AVFoundation
import QuartzCore

class TimeTracker {
    typealias ListeningIntervalTuple = (startInterval: NSTimeInterval?, endInterval: NSTimeInterval?)
    
    let languageId: LanguageId
    let bookId: BookId
    
    var currentListeningInterval: ListeningIntervalTuple = (startInterval: nil, endInterval: nil)
    var listeningIntervals: [ListeningIntervalTuple] = []
    
    var loadingStart: CFTimeInterval?
    
    init(languageId: LanguageId, bookId: BookId) {
        self.languageId = languageId
        self.bookId = bookId
    }
    
    // Loading
    func startLoadingTimeInterval() {
        loadingStart = CACurrentMediaTime()
    }
    
    func endLoadingTimeInterval() {
        if let loadingStart = loadingStart {
            let elapsedTime = CACurrentMediaTime() - loadingStart
            
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(GAIFields.customDimensionForIndex(1), value: languageId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: bookId)
            
            tracker.send(GAIDictionaryBuilder.createTimingWithCategory("resources", interval: elapsedTime, name: "chapter_audio", label: nil).build() as [NSObject: AnyObject])
        }
        
        loadingStart = nil
    }
    
    // Listening
    func startCurrentTimeInterval(currentTime: CMTime) {
        let startInterval = CMTimeGetSeconds(currentTime)
        if !startInterval.isNaN {
            currentListeningInterval.startInterval = startInterval
        }
    }
    
    func endCurrentTimeInterval(currentTime: CMTime) {
        if currentListeningInterval.startInterval != nil {
            let endInterval = CMTimeGetSeconds(currentTime)
            if !endInterval.isNaN && endInterval > currentListeningInterval.startInterval {
                currentListeningInterval.endInterval = endInterval
                listeningIntervals.append(currentListeningInterval)                
            }
        }
        
        resetCurrentTimeInterval()
    }
    
    func resetCurrentTimeInterval() {
        currentListeningInterval.startInterval = nil
        currentListeningInterval.endInterval = nil
    }
    
    func touchAudio(index: Int) {        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(GAIFields.customDimensionForIndex(1), value: languageId)
        tracker.set(GAIFields.customDimensionForIndex(2), value: bookId)
        
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "player_action", label: "chapter_selected", value: nil).build() as [NSObject: AnyObject])
    }
    
    func trackTotalTimeIntervals() {
        var totalTime: NSTimeInterval = 0.0
        
        let localListeningIntervals = listeningIntervals
        listeningIntervals = []
        
        for listeningInterval in localListeningIntervals {

            if let startInterval = listeningInterval.startInterval {
                if let endInterval = listeningInterval.endInterval {
                    let distance = startInterval.distanceTo(endInterval)
                
                    if distance >= 0 {
                        totalTime += distance
                    } else {
                        logError("End of listening interval was earlier than beginning")
                    }
                } else {
                    logError("End of listening interval was not set")
                }
            } else {
                logError("Start of listening interval was not set")
            }
            
        }
        
        let totalTimeInSeconds = Int(totalTime)
        let tracker = GAI.sharedInstance().defaultTracker

        tracker.set(GAIFields.customDimensionForIndex(1), value: languageId)
        tracker.set(GAIFields.customDimensionForIndex(2), value: bookId)
        tracker.set(GAIFields.customMetricForIndex(1), value: "\(totalTimeInSeconds)")
        
        logDebug("Total time listened: \(totalTimeInSeconds)")
    }
}