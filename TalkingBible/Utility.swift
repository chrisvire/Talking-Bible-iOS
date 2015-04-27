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

struct Utility {
    static func deviceInformation() -> String {
        let deviceModel = UIDevice.currentDevice().model as NSString
        let osVersion = UIDevice.currentDevice().systemVersion as NSString
        let bundleName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! NSString
        let bundleVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! NSString
        
        let attachedDevices = join(", ", Utility.attachedDevices())
        let networkConnections = join(",", Utility.networkConnections())
        
        let country = NSLocale.currentLocale().localeIdentifier
        
        let languages = join(",", (NSLocale.preferredLanguages() as! [String]))
        
        let defaultUser = DefaultUser.sharedManager
        let bookmark = Bookmark(languageId: defaultUser.languageId, bookId: defaultUser.bookId, chapterId: defaultUser.chapterId)
        
        return "\n\n-------------------\nDevice Information\n-------------------\nModel: \(deviceModel) (iOS \(osVersion))\nAttached Devices: \(attachedDevices)\nNetwork Connection: \(networkConnections)\nPreferred Languages: \(languages)\nCountry: \(country)\n\n-------------------\nApp Information\n-------------------\nBundle Name: \(bundleName)\nBundle Version: \(bundleVersion)\nBookmark: \(bookmark.description)"
    }
    
    static func attachedDevices() -> [String] {
        var devices: [String] = []
        let route = AVAudioSession.sharedInstance().currentRoute
        
        if let outputs = route.outputs {
            for desc in outputs {
                switch desc.portType {
                case AVAudioSessionPortHeadphones:
                    devices.append("Headphones")
                case AVAudioSessionPortAirPlay:
                    devices.append("AirPlay")
                case AVAudioSessionPortCarAudio:
                    devices.append("Car Audio")
                case AVAudioSessionPortUSBAudio:
                    devices.append("USB Audio")
                case AVAudioSessionPortBluetoothHFP:
                    devices.append("Bluetooth Hands-free")
                case AVAudioSessionPortBluetoothA2DP:
                    devices.append("Bluetooth A2DP")
                case AVAudioSessionPortBluetoothLE:
                    devices.append("Bluetooth LE")
                case AVAudioSessionPortHDMI:
                    devices.append("HDMI")
                case AVAudioSessionPortLineOut:
                    devices.append("Line Out")
                case AVAudioSessionPortBuiltInSpeaker:
                    devices.append("Built-in Speaker")
                default:
                    break
                }
            }
        }
        
        if devices.count == 0 {
            devices.append("None detected")
        }
        
        return devices
    }
    
    static func networkConnections() -> [String] {
        var connections: [String] = []
        
        let reach = Reachability.reachabilityForInternetConnection()
        
        if reach.isReachableViaWWAN() {
            connections.append("WWAN")
        }
        
        if reach.isReachableViaWiFi() {
            connections.append("WiFi")
        }
        
        if connections.count == 0 {
            connections.append("None detected")
        }
        
        return connections
    }
    
    static func safelySetUserDefaultValue(value: AnyObject?, forKey key: String) {
        if let value: AnyObject = value {
            NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
    }
}