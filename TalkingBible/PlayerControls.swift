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

final class PlayerControls: UIView {
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    
    var player = Player.sharedManager
    
    enum PlaybackStatus {
        case NotReady
        case Playing
        case Paused
        case Error
    }
    
    enum PlaylistPosition {
        case NotReady
        case First
        case Middle
        case Last
    }

    var _playbackStatus: PlaybackStatus?
    var _playlistPosition: PlaylistPosition?
    
    var playButtonImageEdgeInsets = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 0)
    var zeroEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var progressSliderTracking = false
    
    let waitingAnimationKey = "waitingAnimation"
    var waitingAnimation: CABasicAnimation?
    
    var duration: Float64?
    
    let onChangeSliderSelector = Selector("onChangeSlider:")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        waitingAnimation = CABasicAnimation(keyPath: "transform.rotation")
        waitingAnimation?.fromValue = 0
        waitingAnimation?.toValue = M_PI
        waitingAnimation?.duration = 1.0
        waitingAnimation?.repeatCount = HUGE
    }
    
    //MARK: - Superview delegation
    var playbackStatus: PlaybackStatus? {
        get {
            return _playbackStatus
        }
        
        set {
            if newValue == _playbackStatus {
                return
            }
            
            _playbackStatus = newValue
            
            switch _playbackStatus {
            case .Some(.Paused):
                playButton.imageView?.layer.removeAnimationForKey(waitingAnimationKey)

                playButton.backgroundColor = UIColor.greenSeaColor()
                
                playButton.imageEdgeInsets = playButtonImageEdgeInsets
                playButton.setImage(ImagesCatalog.BookDetail.Play, forState: .Normal)
                playButton.setImage(ImagesCatalog.BookDetail.PlayFilled, forState: .Highlighted)
                
                playButton.enabled = true
            case .Some(.Playing):
                playButton.imageView?.layer.removeAnimationForKey(waitingAnimationKey)

                playButton.backgroundColor = UIColor.greenSeaColor()
                
                playButton.imageEdgeInsets = zeroEdgeInsets
                playButton.setImage(ImagesCatalog.BookDetail.Pause, forState: .Normal)
                playButton.setImage(ImagesCatalog.BookDetail.PauseFilled, forState: .Highlighted)
                
                playButton.enabled = true
            case .Some(.NotReady):
                playButton.imageView?.layer.removeAnimationForKey(waitingAnimationKey)

                playButton.backgroundColor = UIColor.greenSeaColor()
                
                playButton.imageEdgeInsets = zeroEdgeInsets
                playButton.setImage(ImagesCatalog.BookDetail.Update, forState: .Disabled)
                playButton.imageView?.layer.addAnimation(waitingAnimation, forKey: waitingAnimationKey)
                
                playButton.enabled = false
            case .Some(.Error):
                playButton.imageView?.layer.removeAnimationForKey(waitingAnimationKey)

                playButton.backgroundColor = UIColor.pomegranateColor()

                playButton.imageEdgeInsets = zeroEdgeInsets
                playButton.setImage(ImagesCatalog.BookDetail.Error, forState: .Disabled)
                
                playButton.enabled = false
            default:
                break
            }
        }
    }
    
    var playlistPosition: PlaylistPosition? {
        get {
            return _playlistPosition
        }
        
        set {
            _playlistPosition = newValue
            
            switch _playlistPosition {
            case .Some(.Last):
                nextButton.enabled = false
            default:
                nextButton.enabled = true
            }
        }
    }
    
    // MARK: UI Updaters
    func updateTime(time: CMTime) {
            var elapsedTime = CMTimeGetSeconds(time)

            updateElapsedTime(elapsedTime)
        
            progressSlider.value = Float(elapsedTime)
    }
    
    func updateElapsedTime(elapsedTime: Float64) {
        if progressSlider.maximumValue.isNaN || progressSlider.maximumValue < Float(elapsedTime) {
            return
        }
        
        if let duration = duration {
            var remainingTime = duration - elapsedTime
            
            let date = NSDate(timeIntervalSince1970: remainingTime)
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            
            if remainingTime > 3600.0 {
                dateFormatter.dateFormat = "'-'HH:mm:ss"
            } else {
                dateFormatter.dateFormat = "'-'mm:ss"
            }
            
            remainingTimeLabel.text = dateFormatter.stringFromDate(date)
        }
    }
    
    func setMaximumTime(time: CMTime) {
        let duration = CMTimeGetSeconds(time)
        
        if !duration.isNaN && duration >= 0.0 {
            self.duration = duration
            progressSlider.maximumValue = Float(duration)
            progressSlider.minimumValue = 0.0
            progressSlider.value = 0.0
        }
    }
    
    //MARK: - UI Events
    @IBAction func playButtonPressed(sender: UIButton) {
        player.toggleItem()
    }
    
    @IBAction func previousButtonPressed(sender: UIButton) {
        player.previousPlayerItem()
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        player.nextPlayerItem()
    }
    
    @IBAction func progressSliderChanged(sender: UISlider, forEvent event: UIEvent) {
        let touch = event.allTouches()?.first as! UITouch
        
        switch touch.phase {
        case .Began:
            player.pauseItem()
            fallthrough
        case .Moved:
            progressSliderTracking = true
            updateElapsedTime(Float64(sender.value))
        case .Ended:
            player.seekToTime(sender.value, completionHandler: {
                _ in
                self.progressSliderTracking = false
                self.player.playItem()
            })
        case .Cancelled:
            progressSliderTracking = false
        case .Stationary:
            break
        }
    }
}

extension PlayerControls {
    override func accessibilityIncrement() {
        player.seekIncrementally()
    }
    
    override func accessibilityDecrement() {
        player.seekDecrementally()
    }
}