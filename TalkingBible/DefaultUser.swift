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
import CoreData

final public class DefaultUser {
    private struct Keys {
        static let languageId = "languageId"
        static let bookId = "bookId"
        static let chapterId = "chapterId"
        static let chapterInterval = "chapterInterval"
    }
    
    private let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    init() {
        _languageId = defaults.stringForKey(Keys.languageId) ?? Language.defaultLanguageId()
        _bookId = defaults.stringForKey(Keys.bookId) ?? Book.defaultBookId(languageId: _languageId)
        _chapterId = defaults.integerForKey(Keys.chapterId) ?? Chapter.defaultChapterId(languageId: _languageId, bookId: _bookId)
        _chapterInterval = defaults.doubleForKey(Keys.chapterInterval) ?? 0
    }
    
    class var sharedManager: DefaultUser {
        struct Singleton {
            static let defaultUser = DefaultUser()
        }
        
        return Singleton.defaultUser
    }
    
    func save() {
        Utility.safelySetUserDefaultValue(_languageId, forKey: Keys.languageId)
        Utility.safelySetUserDefaultValue(_bookId, forKey: Keys.bookId)
        Utility.safelySetUserDefaultValue(_chapterId, forKey: Keys.chapterId)
        Utility.safelySetUserDefaultValue(_chapterInterval, forKey: Keys.chapterInterval)
        
        defaults.synchronize()
    }
    
    func set(bookmark: Bookmark) {
        let oldLanguageId = _languageId
        let oldBookId = _bookId
        let oldChapterId = _chapterId
        
        languageId = bookmark.languageId
        bookId = bookmark.bookId ?? oldBookId
        
        if bookmark.chapterId != nil {
            chapterId = bookmark.chapterId
        } else if bookId != oldBookId {
            chapterId = nil
        }
        
        if _languageId != oldLanguageId || _bookId != oldBookId || _chapterId != oldChapterId {
            chapterInterval = 0.0
        }
    }
    
    private var _languageId: LanguageId?
    var languageId: LanguageId? {
        get {
            return _languageId
        }
        
        set {
            
            // This is tweaked slightly from the rest in order to allow passing "default" as the language in a bookmark
            if Language.exists(languageId: newValue) {
                _languageId = newValue
            } else if _languageId == nil {
                _languageId = Language.defaultLanguageId()
            }
            
            postNotification(languageChangeNotification, languageId)
        }
    }
    
    private var _bookId: BookId?
    var bookId: BookId? {
        get {
            return _bookId
        }
        
        set {
            if Book.exists(bookId: newValue, withLanguageId: _languageId) {
                _bookId = newValue
            } else {
                _bookId = Book.defaultBookId(languageId: _languageId)
            }
            
            postNotification(bookChangeNotification, bookId)
        }
    }
    
    private var _chapterId: Int?
    var chapterId: Int? {
        get {
            return _chapterId
        }
        
        set {
            if let newValue = newValue {
                if Chapter.exists(chapterId: newValue, withBookId: _bookId, withLanguageId: _languageId) {
                    _chapterId = newValue
                    
                } else {
                    _chapterId = Chapter.defaultChapterId(languageId: _languageId, bookId: _bookId)
                }
            } else {
                _chapterId = Chapter.defaultChapterId(languageId: _languageId, bookId: _bookId)
            }

            postNotification(chapterChangeNotification, _chapterId)
        }
    }
    
    private var _chapterInterval: NSTimeInterval = 0.0 // Time in seconds, pass an integer
    var chapterInterval: NSTimeInterval {
        get {
            logDebug("Current chapterInterval is \(_chapterInterval)")
            return _chapterInterval
        }
        
        set {
            logDebug("Setting chapterInterval to \(newValue)")
            _chapterInterval = newValue
        }
    }
}