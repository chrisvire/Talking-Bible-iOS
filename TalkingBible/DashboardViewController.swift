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

@objc
final class DashboardViewController: UIViewController {
    var defaultUser = DefaultUser.sharedManager
    
    var language: Language? {
        didSet {
            if let language = language {
                selectLanguageButton.setTitle(language.englishName ∆ "Language name", forState: .Normal)
                selectLanguageButton.enabled = true
            } else {
                selectLanguageButton.enabled = false
            }
        }
    }
    var book: Book? {
        didSet {
            if let book = book {
                selectBookButton.setTitle(book.englishName ∆ "Book name", forState: .Normal)
                selectBookButton.enabled = true
            } else {
                selectBookButton.enabled = false
            }
        }
    }
    
    var bookmarkReceivedObserver: NotificationObserver?
    var languageChangeObserver: NotificationObserver?
    var bookChangeObserver: NotificationObserver?
    
    @IBOutlet weak var continueProgressView: UIView!
    @IBOutlet weak var selectLanguageView: UIView!
    @IBOutlet weak var selectBookView: UIView!

    @IBOutlet weak var continueProgressButton: UIButton!
    @IBOutlet weak var selectLanguageButton: UIButton!
    @IBOutlet weak var selectBookButton: UIButton!
    
    @IBOutlet weak var continueProgressCaret: UIImageView!
    @IBOutlet weak var selectLanguageCaret: UIImageView!
    @IBOutlet weak var selectBookCaret: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configureFlatNavigationBarWithColor(UIColor.wetAsphaltColor())
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.cloudsColor()]
//        navigationController?.view.backgroundColor = view.backgroundColor

        navigationItem.title = "Talking Bible" ∆ "Talking Bible"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        selectLanguageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectLanguageButton.titleLabel?.textAlignment = .Center
        selectLanguageButton.titleLabel?.numberOfLines = 2
        
        selectBookButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectBookButton.titleLabel?.textAlignment = .Center
        selectBookButton.titleLabel?.numberOfLines = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        UIApplication.sharedApplication().statusBarStyle = .Default
        setNeedsStatusBarAppearanceUpdate()

        navigationController?.setNavigationBarHidden(true, animated: true)

        updateLanguage()
        updateBook()
        
        bookmarkReceivedObserver = NotificationObserver(notification: bookmarkReceivedNotification, withName: "DashboardBookmarkReceivedObserver", block: didReceiveBookmark)
        languageChangeObserver = NotificationObserver(notification: languageChangeNotification, withName: "DashboardLanguageChangeObserver", block: didChangeLanguage)
        bookChangeObserver = NotificationObserver(notification: bookChangeNotification, withName: "DashboardBookChangeObserver", block: didChangeBook)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Dashboard View")
    }
    
    // MARK: - Delegates
    func didReceiveBookmark(bookmark: Bookmark) {
        logInfo("Received notification of a new bookmark: \(bookmark.description)")
        
        UIView.animateWithDuration(0.0, animations: {
            self.navigationController?.popToRootViewControllerAnimated(true)
            return
        }, completion: { complete in
            if complete {
                self.defaultUser.set(bookmark)
                
                self.continueProgress()
            }
        })
    }
    
    func didChangeLanguage(languageId: LanguageId?) {
        logInfo("Received notification that language has changed: \(languageId)")
        updateLanguage()
    }
    
    func didChangeBook(bookId: BookId?) {
        logInfo("Received notification that book has changed: \(bookId)")
        updateBook()
    }
    
    // MARK: - Controls
    func updateLanguage() {
        if let languageId = defaultUser.languageId {
            var e: NSError?
            
            let request = NSFetchRequest(entityName: Language.entityName())
            request.predicate = NSPredicate(format: "languageId == %@", languageId)
            request.fetchLimit = 1
            
            let entities = ExternalDataStore.sharedManager.persistentStoreCoordinator.managedObjectContext.executeFetchRequest(request, error: &e)
            
            if e != nil {
                logError("Cannot load default language")
            }
            
            if let entity = entities?.first as? Language {
                language = entity
            }
        }
    }
    
    func updateBook() {
        if let languageId = defaultUser.languageId {
            if let bookId = defaultUser.bookId {
                var e: NSError?
                
                let request = NSFetchRequest(entityName: Book.entityName())
                request.predicate = NSPredicate(format: "collection.language.languageId == %@ AND bookId == %@", languageId, bookId)
                request.fetchLimit = 1
                
                let entities = ExternalDataStore.sharedManager.persistentStoreCoordinator.managedObjectContext.executeFetchRequest(request, error: &e)
                
                if e != nil {
                    logError("Cannot load default book")
                }
                
                if let entity = entities?.first as? Book {
                    book = entity
                }
            }
        }
    }
    
    // MARK: Accessibility
    override func accessibilityPerformMagicTap() -> Bool {
        continueProgress()
        return true
    }
    
    // MARK: IB Actions
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {}
    
    @IBAction func continueProgress() {
        if let bookId = defaultUser.bookId {
            // Set up book table view controller
            let bookTableViewController = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.StoryboardIdentifiers.TBBookTableViewController) as! BookTableViewController
            bookTableViewController.language = language

            // Set up book detail view controller
            let bookDetailViewController = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.StoryboardIdentifiers.TBBookDetailViewController) as! BookDetailViewController
            bookDetailViewController.book = book
            
            // Replace view controllers in stack
            var viewControllers = navigationController?.viewControllers
            viewControllers?.insert(bookTableViewController, atIndex: viewControllers?.endIndex ?? 0)
            viewControllers?.insert(bookDetailViewController, atIndex: viewControllers?.endIndex ?? 0)

            navigationController?.setViewControllers(viewControllers, animated: true)
        } else {
            logWarning("Default book is not set")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some(MainStoryboard.SegueIdentifiers.ShowBooksIdentifier):
            logDebug("Segue to book table view controller")
            let viewController = segue.destinationViewController as! BookTableViewController
            viewController.language = language
        default:
            break
        }
    }
}