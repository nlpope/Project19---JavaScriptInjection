//
//  ActionVC.swift
//  Extension
//
//  Created by Noah Pope on 10/11/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionVC: UIViewController {

    @IBOutlet var script: UITextView!
    var pageTitle       = ""
    var pageURL         = ""
    var previousEntries = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        pullJavaScriptValues()
        setUpKeyboardNotifications()
    }
    
    
    func setUpNavigation() {
        let doneItem                        = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(done))
        let autoScriptItem                  = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(autoScript))
        let customScriptsItem               = UIBarButtonItem(image: SFSymbols.book, style: .plain, target: self, action: #selector(presentCustomScripts))
        navigationItem.rightBarButtonItems  = [doneItem, autoScriptItem, customScriptsItem]
    }
    
    
    func pullJavaScriptValues() {
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                //kUTTypePropertyList
                //UTType.propertyList.identifier
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier, options: nil) { [weak self] (dict, error) in
                    
                    guard let self              = self else { return }
                    guard let itemDictionary    = dict as? NSDictionary else { return }
                    guard let javaScriptValues  = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self.pageTitle              = javaScriptValues["title"] as? String ?? ""
                    self.pageURL                = javaScriptValues["URL"] as? String ?? ""
                    loadEntries()
                    
                    // my issue here was, on autoScript() I kept appending a new line that replicated previous entries before adding the new command
                    DispatchQueue.main.async { self.script.text = self.previousEntries}
                    DispatchQueue.main.async { self.title       = self.pageTitle}
                }
            }
        }
    }

    
    @objc func done() {
        // Return any edited content to the host app (Safari).
        // 2nd issue was here: I was appending a duplicate to previousEntries again instead of just setting it bare.
        // ... necessary for when commands are keyed instead of selected from the autoScript()
        previousEntries                 = script.text
        saveEntries()
        let item                        = NSExtensionItem()
        let argument: NSDictionary      = ["customJavaScript": script.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript            = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
        item.attachments                = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    
    @objc func autoScript() {
        let message                     = "select a prewritten script to execute."
        let ac                          = UIAlertController(title: "Pick A Script", message: message, preferredStyle: .alert)
        //how to append onto an existing string?
        ac.addAction(UIAlertAction(title: "Show Page Title", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.previousEntries.append("\nalert(document.title)")
            self.script.text            = previousEntries
        }))
        ac.addAction(UIAlertAction(title: "Redirect To Google", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.previousEntries.append("\nwindow.location.href = \"https://www.google.com\"")
            self.script.text            = previousEntries
        }))
        ac.addAction(UIAlertAction(title: "Redirect To YouTube", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.previousEntries.append("\nwindow.location.href = \"https://www.youtube.com\"")
            self.script.text            = previousEntries
        }))
        ac.addAction(UIAlertAction(title: "Redirect To GitHub", style: .default, handler: { [weak self] _ in
            guard let self              = self else { return }
            self.previousEntries.append("\nwindow.location.href = \"https://www.github.com\"")
            self.script.text            = previousEntries
        }))
        present(ac, animated: true)
    }
    
    
    @objc func presentCustomScripts() {
        let destVC                      = UserScriptsVC()
        destVC.delegate                 = self
        navigationController?.pushViewController(destVC, animated: true)
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
    
    
    func saveEntries() {
        let jsonEncoder     = JSONEncoder()
        if let dataToSave   = try? jsonEncoder.encode(previousEntries) {
            let defaults    = UserDefaults.standard
            defaults.set(dataToSave, forKey: pageURL)
        } else {
            print("failed to save")
        }
    }
    
    
    func loadEntries() {
        let defaults            = UserDefaults.standard
        if let dataToLoad       = defaults.object(forKey: pageURL) as? Data {
            let jsonDecoder     = JSONDecoder()
            do {
                previousEntries = try jsonDecoder.decode(String.self, from: dataToLoad)
            } catch {
                print("failed to load")
            }
        }
    }
}


// MARK: UserScripts Delegate Methods
extension ActionVC: UserScriptsVCDelegate {
    func apply(userScript script: String) {
        previousEntries.append(script)
        self.script.text    = previousEntries
        saveEntries()
    }
}
