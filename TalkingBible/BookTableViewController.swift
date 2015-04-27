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

final class BookTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var defaultUser = DefaultUser.sharedManager
    
    var language: Language? {
        didSet {
            if let language = language {
                let languageName = language.englishName ∆ "Language name"
                self.navigationItem.title = languageName
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: languageName, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            }
        }
    }
    
    private lazy var persistenceController: MDMPersistenceController = {
        return ExternalDataStore.sharedManager.persistentStoreCoordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = { [unowned self] in
        return self.persistenceController.managedObjectContext
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController = { [unowned self] in
        let languageId = self.language?.languageId

        if languageId == nil {
            logError("Can't find languageId from default user. (Shouldn't happen!)")
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let fetchRequest = NSFetchRequest(entityName: Book.entityName())
        fetchRequest.predicate = NSPredicate(format: "collection.language.languageId == %@", languageId!)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "collection.englishName", ascending: false),
            NSSortDescriptor(key: "position", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "collection.englishName", cacheName: nil)
        
        var e: NSError?
        if !controller.performFetch(&e) {
            logError("Can't fetch books: \(e!.localizedDescription)")
            // TODO tell user, refresh?
        }
        
        return controller
    }()
    
    var tableDataSource: MDMFetchedResultsTableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Book Table View", languageId: defaultUser.languageId!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let info = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let info = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        if let name = info.name {
            return name ∆ "Collection title"
        }
        
        return info.name
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let info = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        var footerTitle: String?
        
        if let version = (info.objects.first as? Book)?.collection?.version {
            let trimmedVersion = version.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if trimmedVersion.isEmpty == false {
                footerTitle = "Text: \(version)"
            }
        }
        
        if let copyright = (info.objects.first as? Book)?.collection?.copyright {
            let trimmedCopyright = copyright.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if trimmedCopyright.isEmpty == false {
                if let existingTitle = footerTitle {
                    footerTitle = "\(existingTitle) - \(copyright)"
                } else {
                    footerTitle = "Text: \(copyright)"
                }
            }
        }
        
        return footerTitle
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel.substituteFontName = "AvenirNext-Medium"
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel.substituteFontName = "AvenirNext-Medium"
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCellIdentifier", forIndexPath: indexPath) as! UniversalTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Helper functions
    
    func configureCell(cell: UniversalTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let book = fetchedResultsController.objectAtIndexPath(indexPath) as! Book
        
//        cell.textLabel?.text = NSLocalizedString(book.englishName, comment: "Bible book name")
        cell.label.text = book.englishName ∆ "Bible book name"
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowBookIdentifier" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let destinationController = segue.destinationViewController as! BookDetailViewController
                
                let book = fetchedResultsController.objectAtIndexPath(indexPath) as! Book
                destinationController.book = book
                
                /// save default user
                let bookmark = Bookmark(languageId: defaultUser.languageId, bookId: book.bookId, chapterId: nil)
                defaultUser.set(bookmark)
            }
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    var storedSteps: [() -> Void] = []
    
    /* called first
    begins update to `UITableView`
    ensures all updates are animated simultaneously */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {}
    
    /* called last
    tells `UITableView` updates are complete */
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if view.window == nil {
            tableView.reloadData()
            return
        }
        
        tableView.beginUpdates()
        
        for step in storedSteps {
            step()
        }
        storedSteps = []
        
        tableView.endUpdates()
    }
    
    /* called:
    - when a new model is created
    - when an existing model is updated
    - when an existing model is deleted */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            storedSteps.append({ [unowned self] in
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                return
            })
        case .Update:
            storedSteps.append({ [unowned self] in
                let cell = self.tableView.dequeueReusableCellWithIdentifier("BookCellIdentifier", forIndexPath: indexPath!) as! UniversalTableViewCell
                self.configureCell(cell, atIndexPath: indexPath!)
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                return
            })
        case .Move:
            storedSteps.append({ [unowned self] in
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                return
            })
        case .Delete:
            storedSteps.append({ [unowned self] in
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                return
            })
        default:
            return
        }
    }
    
    /* called:
    - when a new model is created
    - when an existing model is updated
    - when an existing model is deleted */
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            storedSteps.append({ [unowned self] in
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            })
        case .Delete:
            storedSteps.append({ [unowned self] in
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            })
        default:
            return
        }
    }
}
