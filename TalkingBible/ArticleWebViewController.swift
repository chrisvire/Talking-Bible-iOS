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
import MessageUI

final class ArticleWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bottomButton: UIButton!
    
    var article: Article!

    var mailer: MFMailComposeViewController?
    
    let htmlWrapperWithTitle: String = {
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = ceil(headlineFont.pointSize)
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let bodyFontSize = ceil(bodyFont.pointSize)

        return "<!DOCTYPE html><html><head><style>body{padding: 0 8px} .heading{ font-family: 'Avenir Next', sans-serif; font-weight: 600; font-style: normal; font-size: \(headlineFontSize)px; color: #000000; padding: 8px 0; line-height:1.6;} .content{ font-family: 'Avenir Next', sans-serif;  font-size: \(bodyFontSize)px; color: #313131; line-height:1.6;} p{ line-height: 1.6; text-align: left !important; margin-bottom:\(bodyFontSize * 1.6)px;}</style></head><body><h2 class='heading'>%@</h2><div class='content'>%@</div></body></html>"
        
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch article.specialButton {
        case .Some("showDonationFormViewController"):
            let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomButton, attribute: .Top, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint)
            bottomButton.hidden = false
            bottomButton.setTitle("Donate by Credit Card" ∆ "Donate by Credit Card", forState: .Normal)
        case .Some("showReportProblemViewController"):
            let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomButton, attribute: .Top, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint)
            bottomButton.hidden = false
            bottomButton.setTitle("Report a Problem" ∆ "Report a Problem", forState: .Normal)
        default:
            bottomButton.hidden = true
            let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint)
        }
        
        let safeContent = stripUnwantedHTMLTags(article.htmlContent)
        let wrappedHtmlContent = NSString(format: htmlWrapperWithTitle, article.title, safeContent)
        webView.loadHTMLString(wrappedHtmlContent as String, baseURL: nil)
        webView.scalesPageToFit = false
        webView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreenView("Article View: \(article.title)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stripUnwantedHTMLTags(htmlString: String) -> String {
        return htmlString.stringByReplacingOccurrencesOfString("<p>&nbsp;</p>", withString: "")
    }
    
    // MARK: Special buttons
    @IBAction func bottomButtonPressed(sender: UIButton) {
        switch article.specialButton {
//        case .Some("showDonationFormViewController"):
//            showDonationFormViewController()
        case .Some("showReportProblemViewController"):
            showReportProblemViewController()
        default:
            break
        }
    }
    
    func showReportProblemViewController() {
        if MFMailComposeViewController.canSendMail() {
            mailer = MFMailComposeViewController()
            if let mailer = mailer {
                mailer.mailComposeDelegate = self
                
                mailer.setToRecipients([Config.externalLinks.supportEmailAddress])
                mailer.setSubject("Talking Bible (iOS) support request")
                mailer.setMessageBody("", isHTML: false)
                
                let data = (Utility.deviceInformation() as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                mailer.addAttachmentData(data, mimeType: "UTF-8", fileName: "device_information.txt")
                
                mailer.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
                
                self.presentViewController(mailer, animated: true, completion: nil)
            } else {
                let alertView = UIAlertView(title: "Unable to send mail", message: "Have you configured any email account in your phone? Please check.", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        } else {
            let alertView = UIAlertView(title: "Unable to send mail", message: "Have you configured any email account in your phone? Please check.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
//    func showDonationFormViewController() {
//        logInfo("Showing donation form controller")
//        let donationFormViewController = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.StoryboardIdentifiers.TBDonationFormViewController) as DonationFormViewController
//        navigationController?.pushViewController(donationFormViewController, animated: true)
//    }
}

extension ArticleWebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }
}

extension ArticleWebViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true) {
            
        }
        
        if result.value == MFMailComposeResultSent.value {
            let alertView = UIAlertView(title: "Mail sent.", message: "Thanks for contacting Talking Bibles. We will reply shortly.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
}
