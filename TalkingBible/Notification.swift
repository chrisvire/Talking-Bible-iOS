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

class Box<T> {
    let unbox: T
    init(_ value: T) { self.unbox = value }
}

class Notification<A> {
    let name: String
    var observers: [String: NSObjectProtocol] = [:]
    
    init(name: String) {
        self.name = name
    }
}

func postNotification<A>(note: Notification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NSNotificationCenter.defaultCenter().postNotificationName(note.name, object: nil, userInfo: userInfo)
}

class NotificationObserver {
    let observer: NSObjectProtocol
    
    init<A>(notification: Notification<A>, withName observerName: String, block aBlock: A -> ()) {
        if let observer = notification.observers[observerName] {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(notification.name, object: nil, queue: nil) { note in
            if let value = (note.userInfo?["value"] as? Box<A>)?.unbox {
                aBlock(value)
            } else if let object = note.object as? A {
                aBlock(object)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
        
        notification.observers[observerName] = observer
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}