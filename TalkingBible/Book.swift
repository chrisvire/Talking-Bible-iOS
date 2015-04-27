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

@objc(Book)
final class Book: _Book {

	// Custom logic goes here.

    class func exists(#bookId: BookId?, withLanguageId languageId: LanguageId?) -> Bool {
        if let bookId = bookId {
            if let languageId = languageId {
                let bookQuery = Query<Book>(entityName: Book.entityName())
                let predicate = NSPredicate(format: "bookId == %@ AND collection.language.languageId == %@", bookId, languageId)
                
                if let entity = bookQuery.first(predicate, sortDescriptors: []) {
                    return true
                }
            }
        }
        
        return false
    }
    
    class func defaultBookId(#languageId: LanguageId?) -> BookId? {
        if let languageId = languageId {
            let predicate = NSPredicate(format: "collection.language.languageId == %@", languageId)
            let sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
            
            let bookQuery = Query<Book>(entityName: Book.entityName())
            if let entity = bookQuery.first(predicate, sortDescriptors: sortDescriptors) {
                return entity.bookId
            }
        }
        
        return nil
    }
}

typealias BookId = String