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

import Swift
import Foundation
import AVFoundation

final class Player: NSObject {
    class var sharedManager: Player {
        struct Singleton {
            static let player = Player()
        }
        
        return Singleton.player
    }
    
    let reach: Reachability
    var machine: StateMachine<Player>!
    
    enum PlayerState: Int {
        case Unknown        = 0
        case NoConnection   = 1
        case Unplayable     = 2
        case NotReady       = 3
        case AlmostReady    = 4
        case Ready          = 5
        case Playing        = 6
        case Paused         = 7
        
        func description() -> String {
            let descriptions = [
                "Unknown",
                "NoConnection",
                "Unplayable",
                "NotReady",
                "AlmostReady",
                "Ready",
                "Playing",
                "Paused"
            ]
            
            return descriptions[self.hashValue]
        }
    }
    
    var onReady: (() -> ())?
    
    typealias PlayerItemQueue = [AVPlayerItem]
    
    struct Constants {
        struct KeyPaths {
            static let currentItem = "currentItem"
            static let status = "status"
            static let rate = "rate"
            static let duration = "duration"
        }
        
        static let interval = CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC))
    }
    
    private var player: AVPlayer! {
        willSet {
            if let player = player {
                logInfo("Removing player observers")
                player.removeObserver(self, forKeyPath: Constants.KeyPaths.currentItem)
                player.removeObserver(self, forKeyPath: Constants.KeyPaths.status)
                player.removeObserver(self, forKeyPath: Constants.KeyPaths.rate)
                
                for timeObserver in timeObservers {
                    player.removeTimeObserver(timeObserver)
                }
                
                timeObservers = []
            }
        }
        
        didSet {
            logInfo("Adding player observers")
            player.addObserver(self, forKeyPath: Constants.KeyPaths.currentItem, options: .New, context: nil)
            player.addObserver(self, forKeyPath: Constants.KeyPaths.status, options: .New, context: nil)
            player.addObserver(self, forKeyPath: Constants.KeyPaths.rate, options: .Initial | .New, context: nil)
            
            timeObservers.append(player.addPeriodicTimeObserverForInterval(Constants.interval, queue: nil) { time in
                if time.flags == CMTimeFlags.Valid {
                    postNotification(playerTimeUpdatedNotification, time)
                }
            })
        }
    }
    
    private var mp3Queue: [String]!
    private var playerItemQueue: PlayerItemQueue! {
        willSet {
            if let queue = playerItemQueue {
                logInfo("Removing \(queue.count) observers from playerItemQueue")
                for playerItem in queue {
                    playerItem.removeObserver(self, forKeyPath: Constants.KeyPaths.status, context: nil)
                }
            }
        }
        
        didSet {
            logInfo("Adding \(playerItemQueue.count) observers to playerItemQueue")

            for playerItem in playerItemQueue {
                playerItem.addObserver(self, forKeyPath: Constants.KeyPaths.status, options: .New, context: nil)
            }
        }
    }
    
    var currentTime: CMTime {
        return player.currentTime()
    }
    
    var duration: CMTime {
        return player.currentItem?.duration ?? CMTimeMake(0, 16)
    }
        
    private var _currentPlayerItemIndex: Int = 0
    
    var currentPlayerItemIndex: Int {
        get {
            return _currentPlayerItemIndex
        }
    }
    
    /// Strong Links
    private var timeObservers = [AnyObject]()
    
    /// Time Tracking
    
    private var _currentPercentComplete: Float {
        let currentTime = player.currentTime()
        
        if let currentDuration = player.currentItem?.duration {
            return Float(CMTimeGetSeconds(currentTime)) / Float(CMTimeGetSeconds(currentDuration))
        }
        
        return Float(0)
    }
    
    override init() {
        reach = Reachability.reachabilityForInternetConnection()

        super.init()
        
        machine = StateMachine(initialState: .NotReady, delegate: self)
        
        replacePlayer()
    }
    
    // MARK: Setup
    private func replaceQueue() {
        var tempPlayerItemQueue = [AVPlayerItem]()
        
        for mp3 in mp3Queue {
            var playerItem = AVPlayerItem(URL: NSURL(string: mp3))
            tempPlayerItemQueue.append(playerItem)
        }
        
        playerItemQueue = tempPlayerItemQueue
    }
    
    private func replacePlayer() {
        logInfo("Replacing player")
        machine.state = .NotReady

        player = AVPlayer()
    }
    
    private func recoverFromFailure() {
        dispatch_async(dispatch_get_main_queue()) {
            self.replaceQueue()
            self.replacePlayer()
            
            self.selectPlayerItem(self._currentPlayerItemIndex, timeInterval: 0.0)
        }
    }
    
    // MARK: Public methods
    func playItem() {
        player.play()
    }
    
    func pauseItem() {
        onReady = nil
        player.pause()
    }
    
    func toggleItem() {
        switch machine.state {
        case .Playing:
            onReady = nil
            player.pause()
        case .Ready, .Paused:
           player.play()
        default:
            break
        }
    }
    
    func nextPlayerItem() {
        let nextPlayerItemIndex = _currentPlayerItemIndex + 1
        
        if nextPlayerItemIndex < playerItemQueue.count {
            selectPlayerItem(nextPlayerItemIndex, timeInterval: 0.0)
        }
    }
    
    func previousPlayerItem() {
        if player.rate > 0.0 && player.error == nil {
            if _currentPercentComplete > 0.1 || _currentPlayerItemIndex == 0 {
                seekToTime(Float(0)) { _ in }
                return
            }
        }
        
        let previousPlayerItemIndex = _currentPlayerItemIndex - 1
        
        if previousPlayerItemIndex >= 0 {
            selectPlayerItem(previousPlayerItemIndex, timeInterval: 0.0)
        }
    }
    
    func seekToTime(time: Float, completionHandler: (Bool) -> ()) {
        let status = player.currentItem.status as AVPlayerItemStatus
        if status == .ReadyToPlay {
            player.currentItem.seekToTime(CMTimeMakeWithSeconds(Float64(time), player.currentItem.duration.timescale), completionHandler: completionHandler)
        } else {
            completionHandler(false)
        }
    }
    
    func seekIncrementally() {
        let currentTime = player.currentTime()
        
        if let currentDuration = player.currentItem?.duration {
            let playerItem = playerItemQueue[_currentPlayerItemIndex]
            
            let fifteenSecondsLater = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) + 15, currentTime.timescale)
            
            if CMTimeCompare(fifteenSecondsLater, currentDuration) <= 0 {
                playerItem.seekToTime(fifteenSecondsLater)
            } else {
                playerItem.seekToTime(currentDuration)
            }
        }
    }
    
    func seekDecrementally() {
        let currentTime = player.currentTime()
        
        if let currentDuration = player.currentItem?.duration {
            let playerItem = playerItemQueue[_currentPlayerItemIndex]
            
            let fifteenSecondsEarlier = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) - 15, currentTime.timescale)
            
            if CMTimeCompare(fifteenSecondsEarlier, currentDuration) >= 0 {
                playerItem.seekToTime(fifteenSecondsEarlier)
            } else {
                playerItem.seekToTime(CMTimeMakeWithSeconds(0, currentTime.timescale))
            }
        }
    }
    
    func replaceQueue(queue: [String]) {
        mp3Queue = queue
        
        _currentPlayerItemIndex = 0
        
        replaceQueue()
        replacePlayer()
    }
    
    func selectPlayerItem(index: Int, timeInterval: NSTimeInterval) {
        if playerItemQueue.count <= index {
            return
        }
        
        _currentPlayerItemIndex = index
        
        postNotification(playerItemInQueueChangedNotification, _currentPlayerItemIndex)
        
        self.player.replaceCurrentItemWithPlayerItem(playerItemQueue[index])

        onReady = {
            self.onReady = nil
            
            self.seekToTime(Float(timeInterval), completionHandler: { success in
                if success {
                    self.playItem()
                }
            })
            
            return
        }
    }

    // MARK: Observers
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch (object, keyPath) {
        case (let player as AVPlayer, Constants.KeyPaths.status):
            switch player.status {
            case .Failed:
                handleFailure(player: player)
            default:
                logInfo("AVPlayer is \(player.status.rawValue)")
            }
        case (let player as AVPlayer, Constants.KeyPaths.rate):
            if player.rate > 0.0 && player.error == nil {
                machine.state = .Playing
            } else {
                machine.state = .Paused
            }
        case (let player as AVPlayer, Constants.KeyPaths.currentItem):
            machine.state = .AlmostReady
        case (let currentItem as AVPlayerItem, Constants.KeyPaths.status):
            switch currentItem.status {
            case .ReadyToPlay:
                machine.state = .Ready
            case .Failed:
                handleFailure(playerItem: currentItem)
            default:
                logWarning("AVPlayerItem status is unknown")
            }
        default:
            logWarning("\(keyPath) happened with \(object), which is unimplemented")
        }
    }
    
    // MARK: Error Handling
    
    private func handleFailure(#player: AVPlayer) {
        logError("AVPlayer failed because: [\(player.error.code)] \(player.error.localizedDescription)")
        
        machine.state = .Unplayable
        
        recoverFromFailure()
    }
    
    private func handleFailure(playerItem item: AVPlayerItem) {
        logError("AVPlayerItem [\(item.asset)] failed because: [\(item.error.code)] \(item.error.localizedDescription)")

        switch item.error.code {
        case -1003:
            fallthrough
        case -1100:
            logWarning("AVPlayerItem is unplayable")
            machine.state = .Unplayable
        case -1005, -1009:
            logWarning("AVPlayer has no connection")
            machine.state = .NoConnection
        default:
            recoverFromFailure()
        }
    }
    
    private func doWhenReachable(completionHandler: () -> ()) {
        reach.reachableBlock = { (reach: Reachability!) in
            reach.stopNotifier()
            
            completionHandler()
        }
        
        reach.startNotifier()
    }
}

extension Player: StateMachineDelegateProtocol{
    typealias StateType = PlayerState
    
    func shouldTransitionFrom(from:StateType, to:StateType)->Bool{
//        logDebug("should? from: \(from.description()), to: \(to.description())")

        switch (from, to){
        case (.NoConnection, .NoConnection), (.NotReady, .NotReady), (.AlmostReady, .AlmostReady):
            return false
        case (_, .NoConnection):
            doWhenReachable { [unowned self] in
                self.recoverFromFailure()
            }
            
            return true
        case (.NoConnection, _):
            return reach.isReachable()
        case (_, .Unplayable):
            if !reach.isReachable() {
                machine.state = .NoConnection
                return false
            }
            
            return true
        case (_, .Ready):
            if !reach.isReachable() {
                machine.state = .NoConnection
                
                return false
            }
            
            postNotification(playerDurationUpdatedNotification, self.player.currentItem.duration)
            
            onReady?()
            
            return true
        case (.NotReady, .Paused), (.AlmostReady, .Paused), (.Ready, .Paused):
            return false
        case (_, .AlmostReady), (_, .NotReady), (_, .Unknown), (_, .Paused), (_, .Playing):
            return true
        default:
            return false
        }
    }
    
    func didTransitionFrom(from:StateType, to:StateType){
        postNotification(playerStateChangedNotification, to)
        
//        logDebug("did. from: \(from.description()), to: \(to.description())")
    }
}