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
import CoreData

final class LanguageTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var defaultUser = DefaultUser.sharedManager
    
    var searchBar: UISearchBar?
    
    private lazy var persistenceController: MDMPersistenceController = {
        return ExternalDataStore.sharedManager.persistentStoreCoordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistenceController.managedObjectContext
    }()
    
    let fetchedResultsControllerCache = "LanguageTableFetchedResultsCache"
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        var fetchRequest = NSFetchRequest(entityName: Language.entityName())
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "englishName", ascending: true, selector: Selector("localizedCaseInsensitiveCompare:"))
        ]
        fetchRequest.fetchBatchSize = 20
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: self.fetchedResultsControllerCache)
        
        var e: NSError?
        if !controller.performFetch(&e) {
            logError("Can't fetch languages: \(e!.localizedDescription)")
            self.navigationController?.popToRootViewControllerAnimated(true)
            //TODO tell user
        }
        
        controller.delegate = self
        
        return controller
    }()
    
    var searchResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchDisplayController?.searchResultsTableView.registerClass(UniversalTableViewCell.classForCoder(), forCellReuseIdentifier: MainStoryboard.ReuseIdentifiers.LanguageCellIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Language Table View")
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
//        return fetchedResultsController.sections?.count ?? 0
        return fetchedResultsControllerForTableView(tableView)?.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return fetchedResultsControllerForTableView(tableView)?.sections![section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UniversalTableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MainStoryboard.ReuseIdentifiers.LanguageCellIdentifier, forIndexPath: indexPath) as! UniversalTableViewCell
        
        self.configureCell(tableView, cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let languageForRow = fetchedResultsControllerForTableView(tableView)?.objectAtIndexPath(indexPath) as! Language
        
        let bookmark = Bookmark(languageId: languageForRow.languageId, bookId: nil, chapterId: nil)
        defaultUser.set(bookmark)
        
        if searchDisplayController?.active == true {
            searchDisplayController?.setActive(false, animated: true)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helpers
    func configureCell(tableView: UITableView, cell: UniversalTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let language = fetchedResultsControllerForTableView(tableView)?.objectAtIndexPath(indexPath) as! Language
        
        cell.label.text = language.englishName ∆ "Language name"
        
        if searchDisplayController?.active == false && language.languageId == defaultUser.languageId {
            let accessoryView = UIImageView(image: ImagesCatalog.UserInterface.Checkmark)
            accessoryView.frame = CGRectMake(0, 0, 24, 24)
            cell.accessoryView = accessoryView
        } else {
            cell.accessoryView = nil
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
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
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        
        if self.view.window == nil {
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
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView

        switch type {
        case .Insert:
            storedSteps.append({ _ in
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                return
            })
        case .Update:
            storedSteps.append({ _ in
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            })
        case .Move:
            storedSteps.append({ _ in
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            })
        case .Delete:
            storedSteps.append({ _ in
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
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
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView

        switch type {
        case .Insert:
            storedSteps.append({
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            })
        case .Delete:
            storedSteps.append({
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            })
        default:
            return
        }
    }
    
    // MARK: - Core Data Helpers
    func fetchedResultsControllerForTableView(tableView: UITableView) -> NSFetchedResultsController? {
        return tableView == searchDisplayController?.searchResultsTableView ? searchResultsController! : fetchedResultsController
    }
    
    func allLanguagesFetchRequest(predicate: NSPredicate?) -> NSFetchRequest {
        var fetchRequest = NSFetchRequest(entityName: Language.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "englishName", ascending: true)
        ]
        fetchRequest.fetchBatchSize = 20
        return fetchRequest
    }
}

extension LanguageTableViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchDisplayController(controller: UISearchDisplayController, willUnloadSearchResultsTableView tableView: UITableView) {
        searchResultsController?.delegate = nil
        searchResultsController = nil
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        
        let predicate = NSPredicate(format: "englishName CONTAINS[cd] %@", searchString.lowercaseString)
        
        searchResultsController = NSFetchedResultsController(fetchRequest: allLanguagesFetchRequest(predicate), managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        var fetchError: NSError?
        searchResultsController?.performFetch(&fetchError)
        
        if let e = fetchError {
            logError(e.localizedDescription)
            return false
        }
        
        return true
    }
}