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
    var pageTitle       = ""
    var pageURL         = ""
    var previousEntry   = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        pullJavaScriptValues()
        setUpKeyboardNotifications()
    }
    
    
    func setUpNavigation() {
        let doneItem                        = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(done))
        let autoScriptItem                  = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(autoScript))
        navigationItem.rightBarButtonItems  = [doneItem, autoScriptItem]
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
    
    
    @IBAction func autoScript() {
        let msg                         = "select a prewritten script to execute."
        let ac                          = UIAlertController(title: "Pick A Script", message: "select", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Show Page Title", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.script.text            = "alert(document.title)"
        }))
        ac.addAction(UIAlertAction(title: "Redirect To Google", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.script.text            = "window.location.href = \"https://www.google.com\""
        })) 
        ac.addAction(UIAlertAction(title: "Redirect To YouTube", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.script.text            = "window.location.href = \"https://www.youtube.com\""
        }))
        present(ac, animated: true)
    }
    
    
    func setUpKeyboardNotifications() {
        let notificationCenter  = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue         = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame      = keyboardValue.cgRectValue
        let keyboardViewEndFrame        = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification { script.contentInset = .zero }
        else {
            script.contentInset         = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets    = script.contentInset
        
        let selectedRange               = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        
    }
    
    
    func testSave() {
        let jsonEncoder     = JSONEncoder()
        if let dataToSave   = try? jsonEncoder.encode(previousEntry) {
            let defaults    = UserDefaults.standard
            defaults.set(dataToSave, forKey: "randomKey")
        } else {
            print("failed to save")
        }
    }
    
    
    func testLoad() {
        let defaults            = UserDefaults.standard
        if let dataToLoad       = defaults.object(forKey: "randomKey") as? Data {
            let jsonDecoder     = JSONDecoder()
            do {
                previousEntry   = try jsonDecoder.decode(String.self, from: dataToLoad)
            } catch {
                print("failed to load")
            }
        }
    }
}
