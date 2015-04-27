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

//import UIKit

//TODO localize the form

//final class DonationFormViewController: XLFormViewController {
//    
//    @IBOutlet weak var nextBarButton: UIBarButtonItem!
//    
//    struct Constants {
//        static let rowName = "name"
//        static let rowEmail = "email"
//        static let rowPhone = "phone"
//        static let rowAmount = "amount"
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        trackScreenView("Donation View")
//    }
//    
//    override func awakeFromNib() {
//        let form = XLFormDescriptor(title: "Donate by Credit Card")
//        
//        form.assignFirstResponderOnShow = true
//        
//        // Personal information
//        let personalSection = XLFormSectionDescriptor()
//        personalSection.title = "Personal Information"
//        personalSection.footerTitle = "We require your name and email address in order to process your donation."
//        form.addFormSection(personalSection)
//        
//        let nameRow = XLFormRowDescriptor(tag: Constants.rowName, rowType: XLFormRowDescriptorTypeName, title: "Name")
//        nameRow.required = true
//        nameRow.requireMsg = "Name can't be empty."
//        personalSection.addFormRow(nameRow)
//        
//        let emailRow = XLFormRowDescriptor(tag: Constants.rowEmail, rowType: XLFormRowDescriptorTypeEmail, title: "Email")
//        emailRow.required = true
//        emailRow.requireMsg = "Email can't be empty."
//        personalSection.addFormRow(emailRow)
//        
//        let phoneRow = XLFormRowDescriptor(tag: Constants.rowPhone, rowType: XLFormRowDescriptorTypePhone, title: "Phone")
//        personalSection.addFormRow(phoneRow)
//        
//        // Donation
//        let donationSection = XLFormSectionDescriptor()
//        donationSection.title = "Donation"
//        donationSection.footerTitle = "Select a donation amount, then press Next to continue."
//        form.addFormSection(donationSection)
//        
//        let amountRow = XLFormRowDescriptor(tag: Constants.rowAmount, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: "Amount")
//        amountRow.required = true
//        amountRow.requireMsg = "Amount can't be empty."
//        amountRow.selectorOptions = [
//            XLFormOptionsObject(value: UInt(500), displayText: "$5.00"),
//            XLFormOptionsObject(value: UInt(1000), displayText: "$10.00"),
//            XLFormOptionsObject(value: UInt(2500), displayText: "$25.00"),
//            XLFormOptionsObject(value: UInt(5000), displayText: "$50.00"),
//            XLFormOptionsObject(value: UInt(7500), displayText: "$75.00"),
//            XLFormOptionsObject(value: UInt(10000), displayText: "$100.00")
//        ]
//        amountRow.value = XLFormOptionsObject(value: 1000, displayText: "$10.00")
//        donationSection.addFormRow(amountRow)
//        
//        self.form = form
//    }
//    
//
//    
//    @IBAction func rightBarButtonItemPressed(sender: UIBarButtonItem) {
//        // Check validation
//        let validationErrors = formValidationErrors()
//        
//        if validationErrors.count > 0 {
//            showFormValidationError(validationErrors.first as NSError)
//            return
//        }
//        
//        // Stop user from making changes
//        tableView.endEditing(true)
////        tableView.setEditing(false, animated: true)
//        
//        // Get values
//        let values = formValues()
//        
//        let options = STPCheckoutOptions()
//        options.publishableKey = Config.stripe.publishableKey
//        options.appleMerchantId = Config.apple.merchantId
//        options.enablePostalCode = true
//        options.companyName = "Talking Bibles International"
//        options.purchaseDescription = "Mobile Donation"
//        
//        // Form data
//        if let amount = values[Constants.rowAmount] as? XLFormOptionsObject {
//            options.purchaseAmount = amount.valueData() as UInt
//        }
//
//        if let email = values[Constants.rowEmail] as? String {
//            options.customerEmail = email
//        }
//        
//        options.logoColor = UIColor.wetAsphaltColor()
//        let presenter = STPPaymentPresenter(checkoutOptions: options, delegate: self)
//        presenter.requestPaymentFromPresentingViewController(self)
//    }
//}
//
//extension DonationFormViewController: STPPaymentPresenterDelegate {
//    func paymentPresenter(presenter: STPPaymentPresenter!, didCreateStripeToken token: STPToken!, completion: STPTokenSubmissionHandler!) {
//        createBackendChargeWithToken(token, completion: completion)
//    }
//    
//    func paymentPresenter(presenter: STPPaymentPresenter!, didFinishWithStatus status: STPPaymentStatus, error: NSError!) {
//        self.dismissViewControllerAnimated(true, completion: {
//            switch(status) {
//            case .UserCancelled:
//                return // just do nothing in this case
//            case .Success:
//                self.navigationController?.popViewControllerAnimated(true)
//            case .Error:
//                logError("oh no, an error: \(error.localizedDescription)")
//                let alertView = UIAlertView(title: "Oops!", message: "An error occurred while processing your donation.", delegate: nil, cancelButtonTitle: "Ok")
//                alertView.show()
//            }
//        })
//    }
//    
//    // This is optional, and used to customize the line items shown on the Apple Pay sheet.
//    func paymentPresenter(presenter: STPPaymentPresenter!, didPreparePaymentRequest request: PKPaymentRequest!) -> PKPaymentRequest! {
//        let values = formValues()
//
//        if let amount = values[Constants.rowAmount] as? XLFormOptionsObject {
//            let uIntValue = amount.valueData() as UInt
//            let decimalValue = uIntValue / 100
//            let numberValue = NSDecimalNumber(unsignedLong: decimalValue)
//            
//            request.paymentSummaryItems = [
//                PKPaymentSummaryItem(label: "Donation", amount: numberValue)
//            ]
//        }
//        
//        return request
//    }
//    
//    func createBackendChargeWithToken(token: STPToken, completion: STPTokenSubmissionHandler) {
//        let values = formValues()
//
//        let amountValue = values[Constants.rowAmount] as? XLFormOptionsObject
//        let amount = amountValue?.valueData() as UInt
//        
//        let chargeParams = [
//            "token": token.tokenId,
//            "currency": "usd",
//            "amount": amount ?? 0,
//            "email": values[Constants.rowEmail] as? String ?? "",
//            "fullName": values[Constants.rowName] as? String ?? "",
//            "phone": values[Constants.rowPhone] as? String ?? ""
//        ]
//        
//        PFCloud.callFunctionInBackground("charge", withParameters: chargeParams) { (_, error) -> Void in
//            if error != nil {
//                completion(STPBackendChargeResult.Failure, error)
//            }
//            else {
//                completion(STPBackendChargeResult.Success, nil)
//            }
//        }
//    }
//}