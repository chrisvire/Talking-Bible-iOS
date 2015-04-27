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

@objc(Chapter)
final class Chapter: _Chapter {

	// Custom logic goes here.

    var localizedChapterName: String {
        if let position = position {
            if NSString(string: englishName).containsString("Chapter") {
                let chapterNumber = Int(position) + 1
                return String.localizedStringWithFormat("%@ %d", "Chapter" ∆ "Chapter", chapterNumber)
            }
        }
        
        return englishName
    }
    
    
    class func exists(#chapterId: ChapterId?, withBookId bookId: BookId?, withLanguageId languageId: LanguageId?) -> Bool {
        if let languageId = languageId {
            if let bookId = bookId {
                if let chapterId = chapterId {
                    let predicate = NSPredicate(format: "position == %d AND book.bookId == %@ AND book.collection.language.languageId == %@", chapterId, bookId, languageId)
                    
                    let chapterQuery = Query<Chapter>(entityName: Chapter.entityName())
                    if let entity = chapterQuery.first(predicate, sortDescriptors: []) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    class func defaultChapterId(#languageId: LanguageId?, bookId: BookId?) -> ChapterId? {
        if let languageId = languageId {
            if let bookId = bookId {
                let predicate = NSPredicate(format: "book.collection.language.languageId == %@ AND book.bookId == %@", languageId, bookId)
                let sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
                
                let chapterQuery = Query<Chapter>(entityName: Chapter.entityName())
                if let entity = chapterQuery.first(predicate, sortDescriptors: sortDescriptors) {
                    return entity.position?.integerValue
                }
            }
        }
        
        return nil
    }
}

typealias ChapterId = Int