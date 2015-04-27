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

class UniversalTableViewCell: UITableViewCell {
    let label = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupFonts()
        setupContentView()
    }
    
    func setupFonts() {
        let preferredContentSizeCategory = UIApplication.sharedApplication().preferredContentSizeCategory
        
        switch preferredContentSizeCategory {
        case UIContentSizeCategoryAccessibilityExtraExtraExtraLarge, UIContentSizeCategoryAccessibilityExtraExtraLarge, UIContentSizeCategoryAccessibilityExtraLarge, UIContentSizeCategoryAccessibilityLarge, UIContentSizeCategoryAccessibilityMedium, UIContentSizeCategoryExtraExtraExtraLarge, UIContentSizeCategoryExtraExtraLarge, UIContentSizeCategoryExtraLarge:
            label.substituteFontName = "AvenirNextCondensed-Regular"
        default:
            label.substituteFontName = "AvenirNext-Regular"
        }
    }
    
    func setupContentView() {
        contentView.addSubview(label)

        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var topConstraint = NSLayoutConstraint(item: label, attribute: .TopMargin, relatedBy: .Equal, toItem: contentView, attribute: .TopMargin, multiplier: 1, constant: 13)
        
        var bottomConstraint = NSLayoutConstraint(item: label, attribute: .BottomMargin, relatedBy: .Equal, toItem: contentView, attribute: .BottomMargin, multiplier: 1, constant: -10)
        
        var leadingConstraint = NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 18)
        
        var trailingConstraint = NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -10)
        
        contentView.addConstraints([
            topConstraint,
            bottomConstraint,
            leadingConstraint,
            trailingConstraint
        ])
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
