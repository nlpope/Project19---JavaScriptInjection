//
//  ActionViewController.swift
//  Extension
//
//  Created by Noah Pope on 10/11/24.
//

import UIKit
import MobileCoreServices
//import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    var pageTitle   = ""
    var pageURL     = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        pullJavaScriptValues()
    }
    
    
    func setUpNavigation() {
        navigationItem.rightBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    
    func pullJavaScriptValues() {
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                //kUTTypePropertyList
                //UTType.propertyList.identifier
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil) { [weak self] (dict, error) in
                    
                    guard let self              = self else { return }
                    guard let itemDictionary    = dict as? NSDictionary else { return }
                    guard let javaScriptValues  = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self.pageTitle              = javaScriptValues["title"] as? String ?? ""
                    self.pageURL                = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async { self.title = self.pageTitle}
                }
            }
        }
    }

    
    @IBAction func done() {
        // Return any edited content to the host app (Safari).
        let item                        = NSExtensionItem()
        let argument: NSDictionary      = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript            = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments                = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
}
