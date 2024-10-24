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
    weak var delegate: UserScriptsVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
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
        let message                                 = "Create a script and give it a name for quick selects when using this extension"
        let ac                                      = UIAlertController(title: "Add A Script", message: message, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.textFields?[0].placeholder               = "enter description here"
        ac.textFields?[1].placeholder               = "enter JavaScript here"
        
        let saveAction                              = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self                          = self else { return }
            guard let scriptDescript                = ac.textFields?[0].text else {
                ac.textFields?[0].backgroundColor   = .red
                return
            }
            guard let scriptCode                    = ac.textFields?[1].text else {
                ac.textFields?[1].tintColor         = .red
                return
            }
            self.scriptList[scriptDescript]         = scriptCode
            tableView.reloadData()
        }
        
        let cancelAction                            = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addActions(saveAction, cancelAction)
        present(ac, animated: true)
    }
    
    
    #warning("add save/load funcs")

    
    // MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell                                        = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell                                            = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
        
        if #available(iOS 14.0, *) {
            var config                                  = cell.defaultContentConfiguration()
            var scriptListKeysArray                     = Array(scriptList.keys)
            var scriptListValuesArray                   = Array(scriptList.values)
            print(scriptListKeysArray)
            print(scriptListValuesArray)
            
            for scriptKey in scriptListKeysArray {
                
            }
            config.text                             = scriptListKeysArray[indexPath.row]
            config.textProperties.font              = UIFont.systemFont(ofSize: 14)
            config.textProperties.color             = .black
            
            config.secondaryText                    = scriptListValuesArray[indexPath.row]
            config.secondaryTextProperties.font     = UIFont.systemFont(ofSize: 10)
            config.secondaryTextProperties.color    = .gray
            
            cell.contentConfiguration               = config
            
        } else {
            print("else statement reached for cellz")
            for (scriptKey,scriptValue) in scriptList {
                cell.textLabel?.text                        = scriptKey
                cell.textLabel?.font                        = UIFont.systemFont(ofSize: 14)
                cell.textLabel?.textColor                   = .black
                    
                cell.detailTextLabel?.text                  = scriptValue
                cell.detailTextLabel?.font                  = UIFont.systemFont(ofSize: 10)
                cell.detailTextLabel?.textColor             = .gray
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.apply(userScript: "\nwindow.location.href = \"https://www.linkedin.com\"")
        self.navigationController?.popViewController(animated: true)
    }
}
