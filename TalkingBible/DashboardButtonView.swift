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

import UIKit

class DashboardButtonView: UIView {

    @IBOutlet weak var caret: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    let buttonObservableKeyPath = "titleLabel.alpha"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logDebug("Awaking button from nib")

        caret.tintColor = button.titleLabel?.tintColor

        if let image = caret.image {
            logDebug("Swapping image!")
            caret.image = nil
            caret.image = image
        }
        
        button.addObserver(self, forKeyPath: buttonObservableKeyPath, options: .Initial | .New, context: nil)
    }
    
    override func removeFromSuperview() {
        logDebug("Removing button from superview")
        button.removeObserver(self, forKeyPath: buttonObservableKeyPath)
        super.removeFromSuperview()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == buttonObservableKeyPath {
            if let buttonTitleLabelAlpha = button.titleLabel?.alpha {
                caret.alpha = buttonTitleLabelAlpha
            }
        }
    }
}
