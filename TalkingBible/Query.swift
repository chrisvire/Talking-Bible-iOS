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

final class Query<T: NSManagedObject> {
    let entityName: String
    
    init(entityName: String) {
        self.entityName = entityName
    }
    
    func first(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> T? {
        var e: NSError?
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        
        let entities = ExternalDataStore.sharedManager.persistentStoreCoordinator.managedObjectContext.executeFetchRequest(request, error: &e)
        
        if e != nil {
            logError("Could not load \(entityName): \(e?.localizedDescription)")
        }
        
        return entities?.first as? T
    }
}