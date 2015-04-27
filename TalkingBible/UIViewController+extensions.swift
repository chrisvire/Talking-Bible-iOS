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
import UIKit

extension UIViewController {
    func trackScreenView(screenName: String) {
        trackScreenView(screenName, languageId: nil, bookId: nil)
    }
    
    func trackScreenView(screenName: String, languageId: String) {
        trackScreenView(screenName, languageId: languageId, bookId: nil)
    }
    
    func trackScreenView(screenName: String, languageId: String?, bookId: String?) {
        let tracker = GAI.sharedInstance().defaultTracker
        
        if let languageId = languageId {
            tracker.set(GAIFields.customDimensionForIndex(1), value: languageId)
            
            if let bookId = bookId {
                tracker.set(GAIFields.customDimensionForIndex(2), value: bookId)
            }
        }

        tracker.set(kGAIScreenName, value: screenName)
        tracker.send(GAIDictionaryBuilder.createAppView().build() as [NSObject: AnyObject])
    }
}