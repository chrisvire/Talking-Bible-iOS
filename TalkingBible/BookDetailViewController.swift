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
import Foundation
import AVFoundation
import MediaPlayer.MPNowPlayingInfoCenter
import MediaPlayer.MPMediaItem

final class BookDetailViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var playerControls: PlayerControls!
    @IBOutlet weak var chapterTableView: UITableView!
    
    let defaultUser = DefaultUser.sharedManager
    let player = Player.sharedManager
    
    var playerItemDidPlayToEndTimeObserver: NotificationObserver!
    var playerItemDidTimeJumpObserver: NotificationObserver!
    var playerItemInQueueChangeObserver: NotificationObserver!
    var playerStateChangeObserver: NotificationObserver!
    var playerTimeUpdatedObserver: NotificationObserver!
    var playerDurationUpdatedObserver: NotificationObserver!
    
    var book: Book! {
        didSet {
            if let book = book {
                title = book.englishName ∆ "Bible book name"

                nowPlayingInfo.setValuesForKeysWithDictionary([
                    MPMediaItemPropertyAlbumTitle: book.englishName ∆ "Bible book name",
                    MPMediaItemPropertyAlbumTrackCount: book.chapters.count,
                    MPMediaItemPropertyMediaType: MPMediaType.AudioBook.rawValue,
                    MPNowPlayingInfoPropertyPlaybackQueueCount: book.chapters.count
                ])
            }
        }
    }
    
    var timeTracker: TimeTracker?
    var lastTime: CMTime?
        
    var nowPlayingInfo: NSMutableDictionary = [:]
    
    let equalizerImageView: UIImageView = {
        let tintColor = UIColor.greenSeaColor()
        let animationFrames: [UIImage] = [
            ImagesCatalog.BookDetail.Equalizer1.withColor(tintColor),
            ImagesCatalog.BookDetail.Equalizer2.withColor(tintColor),
            ImagesCatalog.BookDetail.Equalizer1.withColor(tintColor),
            ImagesCatalog.BookDetail.Equalizer3.withColor(tintColor),
            ImagesCatalog.BookDetail.Equalizer2.withColor(tintColor)
        ]
        
        let imageView = UIImageView()
        imageView.image = ImagesCatalog.UserInterface.Checkmark
        imageView.tintColor = tintColor
        imageView.animationImages = animationFrames
        imageView.animationDuration = 4
        
        

        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let languageId = self.book.collection?.language?.languageId {
            timeTracker = TimeTracker(languageId: languageId, bookId: self.book.bookId)
        }
                
        playerItemInQueueChangeObserver = NotificationObserver(notification: playerItemInQueueChangedNotification, withName: "BookDetailPlayerItemInQueueChangeObserver", block: playerItemInQueueChanged)
        
        playerStateChangeObserver = NotificationObserver(notification: playerStateChangedNotification, withName: "BookDetailPlayerStateChangeObserver", block: playerStateChanged)
        
        playerTimeUpdatedObserver = NotificationObserver(notification: playerTimeUpdatedNotification, withName: "BookDetailPlayerTimeUpdatedObserver", block: playerTimeUpdated)
        
        playerDurationUpdatedObserver = NotificationObserver(notification: playerDurationUpdatedNotification, withName: "BookDetailPlayerDurationUpdatedObserver", block: playerDurationUpdated)
        
        playerItemDidPlayToEndTimeObserver = NotificationObserver(notification: playerItemDidPlayToEndTimeNotification, withName: "BookDetailPlayerItemDidPlayToEndTimeObserver", block: playerDidPlayToEndTime)
        
        playerItemDidTimeJumpObserver = NotificationObserver(notification: playerItemDidTimeJumpNotification, withName: "BookDetailPlayerItemDidTimeJumpObserver", block: playerItemDidTimeJump)
        
        // Set up subviews
        playerControls.progressSlider.configureFlatSliderWithTrackColor(UIColor.silverColor(), progressColor: UIColor.turquoiseColor(), thumbColor: UIColor.greenSeaColor())
        
        prepareAudio()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.interactivePopGestureRecognizer.delegate = self
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
        
        continueProgress()
        setupRemoteControl()
        
        playerStateChanged(player.machine.state)
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Book Detail View", languageId: book.collection?.language?.languageId, bookId: book.bookId)
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, playerControls.playButton)
    }
    
    override func viewWillDisappear(animated: Bool) {
        player.pauseItem()

        navigationController?.interactivePopGestureRecognizer.delegate = nil
        
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        resignFirstResponder()
        
        timeTracker?.trackTotalTimeIntervals()
        
        super.viewWillDisappear(animated)
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        player.toggleItem()
        
        return true
    }
    
    // MARK: Player events
    func playerStateChanged(state: Player.PlayerState) {
        switch state {
        case .Paused:
            timeTracker?.endCurrentTimeInterval(player.currentTime)
            playerControls.playbackStatus = .Paused
            equalizerImageView.stopAnimating()
        case .Playing:
            timeTracker?.endLoadingTimeInterval()
            timeTracker?.startCurrentTimeInterval(player.currentTime)
            playerControls.playbackStatus = .Playing
            equalizerImageView.startAnimating()
        case .AlmostReady, .NotReady, .Ready, .Unknown:
            playerControls.playbackStatus = .NotReady
            equalizerImageView.stopAnimating()
        case .Unplayable, .NoConnection:
            timeTracker?.endCurrentTimeInterval(player.currentTime)
            playerControls.playbackStatus = .Error
            equalizerImageView.stopAnimating()
        default:
            break
        }
    }
    
    func playerDidPlayToEndTime(item: AVPlayerItem) {
        logInfo("Player did play to end time")
        if playerControls.progressSlider.tracking == false && playerControls.progressSliderTracking == false {
            if player.currentPlayerItemIndex < book.chapters.count - 1 {
                player.nextPlayerItem()
            }
        }
    }
    
    func playerTimeUpdated(time: CMTime) {
        self.lastTime = time
        self.playerControls.updateTime(time)
        
        defaultUser.chapterInterval = CMTimeGetSeconds(time)
    }
    
    func playerDurationUpdated(duration: CMTime) {
        self.playerControls.setMaximumTime(duration)
    }
    
    func playerItemDidTimeJump(item: AVPlayerItem) {
        if let lastTime = self.lastTime {
            timeTracker?.endCurrentTimeInterval(lastTime)
            
            if playerControls.progressSlider.tracking == false && playerControls.progressSliderTracking == false {
                timeTracker?.startCurrentTimeInterval(item.currentTime())
            }
        }
    }
    
    func playerItemInQueueChanged(index: Int) {
        logInfo("Player item changed to index \(index)")

        timeTracker?.startLoadingTimeInterval()
        timeTracker?.touchAudio(index)
        
        let duration = player.duration
        playerControls.setMaximumTime(duration)
        
        switch index {
        case 0:
            playerControls.playlistPosition = .First
        case book.chapters.count - 1:
            playerControls.playlistPosition = .Last
        default:
            playerControls.playlistPosition = .Middle
        }
        
        scrollToCurrentPlayerItem(index)
        
        defaultUser.chapterId = index
    }
    
    // MARK: - Audio Preparation
    func continueProgress() {
        if let chapterId = defaultUser.chapterId {
            if book.chapters.count > chapterId {
                player.selectPlayerItem(chapterId, timeInterval: defaultUser.chapterInterval)
            }
        }
    }
    
    func setupRemoteControl() {
        let currentIndex = player.currentPlayerItemIndex
        
//        TODO fix time in remote control
        let chapter = book.chapters[currentIndex] as! Chapter
        
        let duration = CMTimeGetSeconds(player.duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime)
        
        let info = NSMutableDictionary(dictionary: nowPlayingInfo)
        info.setValuesForKeysWithDictionary([
            MPMediaItemPropertyAlbumTrackNumber: currentIndex,
            MPMediaItemPropertyTitle: chapter.localizedChapterName,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
            MPNowPlayingInfoPropertyPlaybackQueueIndex: currentIndex,
        ])
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info as [NSObject : AnyObject]
    }
    
    func prepareAudio() {
        var audioQueue: [String] = []
        book.chapters.enumerateObjectsUsingBlock { (chapter, idx, stop) in
            if let chapter = chapter as? Chapter {
                audioQueue.append(chapter.mp3)
            }
        }
        
        player.replaceQueue(audioQueue)
    }

    // MARK: - UI Events
    @IBAction func rightBarButtonPressed(sender: UIBarButtonItem) {
        player.pauseItem()
        
        let shareString = "Listen to the Talking Bible with me in \(book.englishName)!"
        
        let bookmark = Bookmark(languageId: book.collection?.language?.languageId, bookId: book.bookId, chapterId: player.currentPlayerItemIndex)        
        let shareViewController = DeepLinks.getActivityViewController(shareString, bookmark: bookmark)
        shareViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        navigationController?.presentViewController(shareViewController, animated: true, completion: nil)
    }
}

extension BookDetailViewController: UIGestureRecognizerDelegate {
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return false
        }
        
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        //TODO implement seeking
        switch event.subtype {
        case .RemoteControlTogglePlayPause:
            player.toggleItem()
        case .RemoteControlPlay:
            player.playItem()
        case .RemoteControlPause:
            player.pauseItem()
        case .RemoteControlNextTrack:
            player.nextPlayerItem()
        case .RemoteControlPreviousTrack:
            player.previousPlayerItem()
        default:
            logWarning("Some other remote event received: \(event.subtype)")
        }
    }
}

extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(book.chapters.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.ReuseIdentifiers.ChapterCellIdentifier, forIndexPath: indexPath) as! UniversalTableViewCell
        
        let chapter = book.chapters[indexPath.row] as! Chapter
        
        cell.label.text = chapter.localizedChapterName
        
        if indexPath.row == player.currentPlayerItemIndex {
            let accessoryView = equalizerImageView
            accessoryView.frame = CGRectMake(0, 0, 24, 24)
            cell.accessoryView = accessoryView
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chapter = book.chapters[indexPath.row] as! Chapter
        
        player.selectPlayerItem(indexPath.row, timeInterval: 0.0)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func scrollToCurrentPlayerItem(index: Int) {
        chapterTableView.reloadData()
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        chapterTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
}