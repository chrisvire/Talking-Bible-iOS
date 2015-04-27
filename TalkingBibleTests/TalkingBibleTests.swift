//
//  TalkingBibleTests.swift
//  TalkingBibleTests
//
//  Created by Clay Smith on 10/30/14.
//  Copyright (c) 2014 Talking Bibles International. All rights reserved.
//

import UIKit
import XCTest
import Foundation

class TalkingBibleTests: XCTestCase {
    var app: UIApplication!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        app = UIApplication.sharedApplication()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testCanOpenURL() {
//        XCTAssert(app.canOpenURL(NSURL(string: "talkingbible://eng/01_matthew/1")!), "Can open talkingbible:// url scheme")
//    }
    
//    func testBookmarkLanguage() {
//        let bookmark = Bookmark(languageId: "eng", bookId: nil, chapterId: nil)
//        XCTAssertNotNil(bookmark.languageId, "Language was bookmarked")
//    }
//    
//    func testBookmarkInvalidLanguage() {
//        let bookmark = Bookmark(languageId: "xxx", bookId: nil, chapterId: nil)
//        XCTAssertNil(bookmark.languageId, "Invalid language was not bookmarked")
//    }
//    
//    func testBookmarkBook() {
//        let bookmark = Bookmark(languageId: "eng", bookId: "01_matthew", chapterId: nil)
//        XCTAssertNotNil(bookmark.bookId, "Book was bookmarked")
//    }
//    
//    func testBookmarkInvalidBook() {
//        let bookmark = Bookmark(languageId: "eng", bookId: "xxx", chapterId: nil)
//        XCTAssertNotNil(bookmark.languageId, "Language was bookmarked")
//        XCTAssertNil(bookmark.bookId, "Invalid book was not bookmarked")
//    }
//    
//    func testBookmarkChapter() {
//        let bookmark = Bookmark(languageId: "eng", bookId: "01_matthew", chapterId: 1)
//        XCTAssertNotNil(bookmark.chapterId, "Chapter was bookmarked")
//    }
//    
//    func testBookmarkInvalidChapter() {
//        let bookmark = Bookmark(languageId: "eng", bookId: "01_matthew", chapterId: 999)
//        XCTAssertNotNil(bookmark.languageId, "Language was bookmarked")
//        XCTAssertNotNil(bookmark.bookId, "Book was bookmarked")
//        XCTAssertNil(bookmark.chapterId, "Invalid chapter was not bookmarked")
//    }
//
//    func testBookmarkFromPath() {
//        let bookmark = Bookmark(path: "eng/01_matthew/1")
//        XCTAssertNotNil(bookmark.languageId, "Language was bookmarked")
//        XCTAssertNotNil(bookmark.bookId, "Book was bookmarked")
//        XCTAssertNotNil(bookmark.chapterId, "Chapter was bookmarked")
//    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
