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

typealias Sections = [String: [Article]]

class KnowledgeBase {
    typealias ArticleSuccessCompletionHandler = Sections! -> Void
    typealias ArticleFailureCompletionHandler = NSError! -> Void
    typealias Sections = [String: [Article]]
    
    let knowledgeBaseUpdatedKey = "knowledgeBaseUpdated"
    
    class var sharedManager: KnowledgeBase {
        struct Singleton {
            static let knowledgeBase = KnowledgeBase()
        }
        
        return Singleton.knowledgeBase
    }
    
    var sections: Sections = [:]
    var sectionTitles: [String] = []
 
    func fetchKBArticles(success: ArticleSuccessCompletionHandler!, failure: ArticleFailureCompletionHandler, usingLocalDatastore: Bool = true) {
        var query = PFQuery(className: "Article")

        let theDate = NSDate()
        
        var usingLocalDatastore = usingLocalDatastore
        if localDatastoreIsFresh() {
            logInfo("Using local datastore for knowledgebase articles")
            query.fromLocalDatastore()
            usingLocalDatastore = true
        } else {
            logInfo("Updating local datastore for knowledgebase articles")
            usingLocalDatastore = false
        }
        
        query.whereKeyExists("sectionTitle")
        query.whereKeyExists("title")
//        query.whereKeyExists("htmlContent")
        query.whereKeyExists("position")
        query.whereKeyExists("specialButton")
        
        query.orderByAscending("sectionTitle")
        query.addAscendingOrder("position")
        
        query.findObjectsInBackgroundWithBlock { result, error in
            if error != nil {
                logError(error!.localizedDescription)
                failure(error)
                return
            }
            
            let items = result as! [Article]
            
            if usingLocalDatastore {
                if items.count == 0 {
                    self.fetchKBArticles(success, failure: failure, usingLocalDatastore: false)
                    return
                }
                
                let sections = self.groupKBArticlesBySection(items)
                success(sections)
                
                return
            }
            PFObject.unpinAllObjectsInBackgroundWithName("Articles") { succeeded, error in
                if let error = error {
                    logError(error.localizedDescription)
                }
                
                PFObject.pinAllInBackground(items, withName: "Articles", block: nil)
                
                let sections = self.groupKBArticlesBySection(items)
                success(sections)
                
                NSUserDefaults.standardUserDefaults().setObject(theDate, forKey: self.knowledgeBaseUpdatedKey)
            }
        }
    }
    
    private func groupKBArticlesBySection(articles: [Article]!) -> Sections {
        var sections: Sections = [:]
        
        for article in articles {
            let sectionTitle = article.sectionTitle
            if sections[sectionTitle] == nil {
                sections[sectionTitle] = []
            }
            
            sections[sectionTitle]?.append(article)
        }
        
        return sections
    }
    
    private func localDatastoreIsFresh() -> Bool {
        let theDate = NSDate()
        
        if let updatedDate = NSUserDefaults.standardUserDefaults().objectForKey(knowledgeBaseUpdatedKey) as? NSDate {
            let daysSinceUpdated = daysBetweenThisDate(updatedDate, andThisDate: theDate)
            if daysSinceUpdated < 3 {
                return true
            }
        }
        
        return false
    }
    
    private func daysBetweenThisDate(fromDateTime:NSDate, andThisDate toDateTime:NSDate)->Int?{
        
        var fromDate:NSDate? = nil
        var toDate:NSDate? = nil
        
        let calendar = NSCalendar.currentCalendar()
        
        calendar.rangeOfUnit(.CalendarUnitDay, startDate: &fromDate, interval: nil, forDate: fromDateTime)
        
        calendar.rangeOfUnit(.CalendarUnitDay, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        if let from = fromDate {
            
            if let to = toDate {
                
                let difference = calendar.components(.CalendarUnitDay, fromDate: from, toDate: to, options: NSCalendarOptions.allZeros)
                
                return difference.day
            }
        }
        
        return nil
    }
}