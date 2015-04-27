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

let bookmarkReceivedNotification: Notification<Bookmark> = Notification(name: "org.talkingbibles.talkingbible.bookmarkReceived")

let languageChangeNotification: Notification<LanguageId?> = Notification(name: "org.talkingbibles.talkingbible.languageChanged")
let bookChangeNotification: Notification<BookId?> = Notification(name: "org.talkingbibles.talkingbible.bookChanged")
let chapterChangeNotification: Notification<ChapterId?> = Notification(name: "org.talkingbibles.talkingbible.chapterChanged")

let playerItemDidPlayToEndTimeNotification: Notification<AVPlayerItem> = Notification(name: AVPlayerItemDidPlayToEndTimeNotification)
let playerItemDidTimeJumpNotification: Notification<AVPlayerItem> = Notification(name: AVPlayerItemTimeJumpedNotification)
let playerItemInQueueChangedNotification: Notification<Int> = Notification(name: "org.talkingbibles.talkingbible.playerItemInQueueChanged")

let playerStateChangedNotification: Notification<Player.PlayerState> = Notification(name: "org.talkingbibles.talkingbible.playerStateChanged")
let playerDurationUpdatedNotification: Notification<CMTime> = Notification(name: "org.talkingbibles.talkingbible.playerDurationUpdated")
let playerTimeUpdatedNotification: Notification<CMTime> = Notification(name: "org.talkingbibles.talkingbible.playerTimeUpdated")