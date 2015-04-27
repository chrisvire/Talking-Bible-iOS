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

@objc(Language)
final class Language: _Language {

	// Custom logic goes here.
    
    class func exists(#languageId: LanguageId?) -> Bool {
        if let languageId = languageId {
            let languageQuery = Query<Language>(entityName: Language.entityName())
            let predicate = NSPredicate(format: "languageId == %@", languageId)
            
            if let entity = languageQuery.first(predicate, sortDescriptors: []) {
                return true
            }
        }
        
        return false
    }
    
    class func defaultLanguageId() -> LanguageId? {
        if let languageId = Config.defaults.languageIds.first {
            let predicate = NSPredicate(format: "languageId == %@", languageId)
            
            let languageQuery = Query<Language>(entityName: Language.entityName())
            if let entity = languageQuery.first(predicate, sortDescriptors: []) {
                return entity.languageId
            } else {
                if let entity = languageQuery.first(nil, sortDescriptors: []) {
                    return entity.languageId
                }
            }
        }
        
        return nil
    }

}

typealias LanguageId = String