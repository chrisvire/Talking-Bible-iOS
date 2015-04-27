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

struct DeepLinks {
    static func branchHandler(params: [NSObject: AnyObject]?, error: NSError?) {
        if error == nil {
            if let params = params {
                logDebug("Received deep link: \(params.description)")
                
                if params["type"] as? String == "bookmark" {
                    let bookmark = Bookmark(
                        languageId: params["language_id"] as? LanguageId,
                        bookId: params["book_id"] as? BookId,
                        chapterId: (params["chapter_id"] as? String)?.toInt()
                    )
                    openBookmark(bookmark)
                }
            }
        }
    }
    
    static func handleDeepLink(url: NSURL) -> Bool {
        // talkingbible://bookmark/eng/01_matthew/1
        if url.scheme == "talkingbible" {
            if url.host == "bookmark" {
                if let path = url.path {
                    let bookmark = Bookmark(path: path)
                    DeepLinks.openBookmark(bookmark)
                    
                    return true
                }
                
                logError("Unspecified deep link url path")
            }
            
            logError("Unrecognized deep link url host")
            return false
        }
        
        logError("Unrecognized deep link url scheme")
        return false
    }
    
    static func openBookmark(bookmark: Bookmark) {
        logDebug("Opening bookmark: \(bookmark.description)")
        
        if bookmark.isEmpty() {
            return
        }
        
        postNotification(bookmarkReceivedNotification, bookmark)
    }
    
    static func getActivityViewController(shareString: String, bookmark: Bookmark) -> UIActivityViewController {
        let defaultURL = Config.externalLinks.listeningWebsite
        
        var params: [String: AnyObject] = [
            "type": "bookmark",
            "language_id": bookmark.languageId ?? "",
            "book_id": bookmark.bookId ?? "",
            "chapter_id": "\(bookmark.chapterId ?? 0)"
        ]
        
        params["$og_title"] = "Talking Bible"
        params["$og_description"] = shareString
        params["$og_image_url"] = Config.externalLinks.shareIcon
        
        params["$desktop_url"] = Config.externalLinks.listeningWebsite
        params["$after_click_url"] = Config.externalLinks.informationalWebsite
        //params["$ios_url"] = Config.externalLinks.iosAppStoreWebsite
        
        let itemProvider = Branch.getBranchActivityItemWithParams(params)
        return UIActivityViewController(activityItems: [shareString, itemProvider], applicationActivities: nil)
    }
}