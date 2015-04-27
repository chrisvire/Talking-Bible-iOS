//
//  BookDetailViewController+Accessibility.swift
//  TalkingBible
//
//  Created by Clay Smith on 1/29/15.
//  Copyright (c) 2015 Talking Bibles International. All rights reserved.
//

import Foundation

extension BookDetailViewController {
    override func accessibilityPerformMagicTap() -> Bool {
        player.toggleItem()
        
        return true
    }
}