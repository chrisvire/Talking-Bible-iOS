////
////  DefaultUserTest.swift
////  TalkingBible
////
////  Created by Clay Smith on 2/6/15.
////  Copyright (c) 2015 Talking Bibles International. All rights reserved.
////
//
//import XCTest
//
//class DefaultUserTest: XCTestCase {
//    private struct Keys {
//        static let languageId = "languageId"
//        static let bookId = "bookId"
//        static let chapterId = "chapterId"
//    }
//    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//      
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        NSUserDefaults.standardUserDefaults().removeObjectForKey(Keys.languageId)
//        NSUserDefaults.standardUserDefaults().removeObjectForKey(Keys.bookId)
//        NSUserDefaults.standardUserDefaults().removeObjectForKey(Keys.chapterId)
//        NSUserDefaults.standardUserDefaults().synchronize()
//
//        super.tearDown()
//    }
//    
//    func testDefaultValues() {
//        let defaultUser = DefaultUser.sharedManager
//        assert(defaultUser.languageId != nil, "Default user defaults to language")
//        assert(defaultUser.bookId != nil, "Default user defaults to book")
//        assert(defaultUser.chapterId != nil, "Default user defaults to chapter")
//    }
//
//    func testSettingValues() {
//        let defaultUser = DefaultUser.sharedManager
//        defaultUser.languageId = "zzz"
//        defaultUser.bookId = "thorough"
//        defaultUser.chapterId = 777
//        defaultUser.save()
//        
//        assert(defaultUser.languageId == "zzz", "Default user stores language")
//        assert(defaultUser.bookId == "thorough", "Default user stores book")
//        assert(defaultUser.chapterId == 777, "Default user stores chapter")
//    }
//    
//    func testRemovingValues() {
//        let defaultUser = DefaultUser.sharedManager
//        defaultUser.languageId = nil
//        defaultUser.bookId = nil
//        defaultUser.chapterId = nil
//        defaultUser.save()
//        
//        assert(defaultUser.languageId == nil, "Default user removes language")
//        assert(defaultUser.bookId == nil, "Default user removes book")
//        assert(defaultUser.chapterId == nil, "Default user removes chapter")
//    }
//
//}
