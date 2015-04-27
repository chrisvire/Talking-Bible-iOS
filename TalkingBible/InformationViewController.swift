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
import UIKit

//TODO localize — will probably require a complete conceptual rewrite. not looking forward to that.

final class InformationViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var sections: Sections = [:]
    var sectionTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        KnowledgeBase.sharedManager.fetchKBArticles(didFetchKBArticles, failure: didNotFetchKBArticles)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Information View")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Parse methods
    func didFetchKBArticles(sections: Sections!) {
        self.sections = sections
        self.sectionTitles = Array(sections.keys).sorted { a, b -> Bool in
            return a < b
        }
        
        self.tableView.reloadData()
    }
    
    func didNotFetchKBArticles(error: NSError!) {
        logError(error.localizedDescription)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowArticleIdentifier" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let destinationController = segue.destinationViewController as! ArticleWebViewController
                
                let sectionTitle = sectionTitles[indexPath.section]
                let articles = sections[sectionTitle]!
                
                let article = articles[indexPath.row]
                destinationController.article = article
            }
        }
    }
}

extension InformationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InformationCellIdentifier", forIndexPath: indexPath) as! UniversalTableViewCell
        
        let sectionTitle = sectionTitles[indexPath.section]
        let articles = sections[sectionTitle]!
        
        let article = articles[indexPath.row]
        cell.label.text = article.title
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        let articles = sections[sectionTitle]!
        
        return articles.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}


