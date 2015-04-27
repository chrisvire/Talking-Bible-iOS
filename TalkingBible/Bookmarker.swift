//
//  Bookmarker.swift
//  TalkingBible
//
//  Created by Clay Smith on 2/2/15.
//  Copyright (c) 2015 Talking Bibles International. All rights reserved.
//

import Foundation

class Bookmarker {
    class func makeBookmarkFromPath(path: String!) -> Bool {
        if path == nil {
            return false
        }

        let bookmark = Bookmark(path: path)
        
        if bookmarkLanguage(bookmark.language) {
            
        }
        
        return false
    }
    
    class func bookmarkLanguage(languageId: String?) -> Bool {
        if let languageId = languageId {
            var e: NSError?
            
            let request = NSFetchRequest(entityName: Language.entityName())
            request.predicate = NSPredicate(format: "languageId == %@", languageId)
            request.fetchLimit = 1
            
            let entities = ExternalDataStore.sharedManager.persistentStoreCoordinator.managedObjectContext.executeFetchRequest(request, error: &e)
            
            if e != nil {
                log.error("Cannot load language")
                return false
            }
            
            if let entity = entities?.first as? Language {
                DefaultUser.sharedManager.languageId = entity.languageId
                return true
            }
        }
        
        return false
    }
}