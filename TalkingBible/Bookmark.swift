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

struct Bookmark: Printable {
    let languageId: String?
    let bookId: String?
    let chapterId: Int?
    
    init(languageId: String?, bookId: String?, chapterId: Int?) {
        self.languageId = languageId
        self.bookId = bookId
        self.chapterId = chapterId
    }
    
    init(pathComponents components: [String]) {
        var pathLanguageId: String?
        var pathBookId: String?
        var pathChapterId: Int?
        
        switch components.count {
        case 3:
            pathChapterId = components[2].toInt()
            fallthrough
        case 2:
            pathBookId = components[1]
            fallthrough
        case 1:
            pathLanguageId = components[0]
        default:
            break
        }
        
        self.init(languageId: pathLanguageId, bookId: pathBookId, chapterId: pathChapterId)
    }
    
    init(path: String) {
        self.init(pathComponents: path.toPathComponents())
    }
    
    var description: String {
        return "Bookmark[languageId: \(languageId), bookId: \(bookId), chapterId: \(chapterId)]"
    }
    
    func isEmpty() -> Bool {
        if self.languageId == nil && self.bookId == nil && self.chapterId == nil {
            return true
        }
        
        return false
    }
}