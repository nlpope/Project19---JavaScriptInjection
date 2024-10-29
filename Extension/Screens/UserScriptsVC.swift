//
//  UserScriptsVC.swift
//  Project19 - JavaScriptInjection
//
//  Created by Noah Pope on 10/22/24.
//

import UIKit

protocol UserScriptsVCDelegate: AnyObject {
    func apply(userScript script: String)
}

class UserScriptsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView       = UITableView()
    let reuseID         = "cellWithSubtitle"
    var scriptList      = [String:String]()
    var scriptListKeys  = [String]()
    weak var delegate: UserScriptsVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        loadScriptList()
        configureTableView()
    }
    
    
    func configureNavigation() {
        view.backgroundColor                = .systemBackground
        title                               = "Custom Scripts"
        let addItem                         = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCustomScript))
        navigationItem.rightBarButtonItems  = [addItem]
    }
    
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame         = view.bounds
        tableView.delegate      = self
        tableView.dataSource    = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
    }
    
    
    @objc func addCustomScript() {
        let message                                 = "Create a script and give it a name for quick selects when using this extension. Be sure to use unique descriptions"
        let ac                                      = UIAlertController(title: "Add A Script", message: message, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.textFields?[0].placeholder               = "enter unique description here"
        ac.textFields?[1].placeholder               = "enter JavaScript here"
        
        let saveAction                              = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self                          = self else { return }
            #warning("test empty textfield behavior")
            guard ac.textFields?[0].hasText != nil else {
                ac.textFields?[0].backgroundColor   = .red
                return
            } 
            guard ac.textFields?[1].hasText != nil else {
                ac.textFields?[1].backgroundColor   = .red
                return
            }
            
            let scriptDescript                      = ac.textFields?[0].text
            let scriptCode                          = ac.textFields?[1].text
            
            self.scriptList[scriptDescript!]        = scriptCode
            scriptListKeys                          = Array(scriptList.keys).sorted()
            saveScriptList()
            tableView.reloadData()
        }
        
        let cancelAction                            = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addActions(saveAction, cancelAction)
        present(ac, animated: true)
    }
    
    
    func saveScriptList() {
        let jsonEncoder     = JSONEncoder()
        if let encodedData  = try? jsonEncoder.encode(scriptList) {
            let defaults    = UserDefaults.standard
            defaults.set(encodedData, forKey: SaveKeys.scriptList)
        } else {
            print("unable to save scriptList")
        }
    }
    
    
    func loadScriptList() {
        let defaults            = UserDefaults.standard
        if let dataToDecode     = defaults.object(forKey: SaveKeys.scriptList) as? Data {
            let jsonDecoder     = JSONDecoder()
            do {
                scriptList      = try jsonDecoder.decode([String:String].self, from: dataToDecode)
            } catch {
                print("could not load data")
            }
            scriptListKeys  = Array(scriptList.keys).sorted()
        }
    }

    
    // MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptListKeys.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell                                            = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        let targetKey                                       = scriptListKeys[indexPath.row]
        cell                                                = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
        
        if #available(iOS 14.0, *) {
            var config                                      = cell.defaultContentConfiguration()
            // scriptListKeys[indexPath.row] = "navYT"
            config.text                                     = targetKey
            config.textProperties.font                      = UIFont.systemFont(ofSize: 14)
            config.textProperties.color                     = .black
            
            config.secondaryText                            = scriptList[targetKey]
            config.secondaryTextProperties.font             = UIFont.systemFont(ofSize: 12)
            config.secondaryTextProperties.color            = .gray
            
            cell.contentConfiguration                       = config
        } else {
            cell.textLabel?.text                            = targetKey
            cell.textLabel?.font                            = UIFont.systemFont(ofSize: 14)
            cell.textLabel?.textColor                       = .black
                
            cell.detailTextLabel?.text                      = scriptList[targetKey]
            cell.detailTextLabel?.font                      = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor                 = .gray
        }
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetKey   = scriptListKeys[indexPath.row]
        delegate.apply(userScript: scriptList[targetKey] ?? "unknown")
        self.navigationController?.popViewController(animated: true)
    }
}
