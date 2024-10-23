//
//  UserScriptsVC.swift
//  Project19 - JavaScriptInjection
//
//  Created by Noah Pope on 10/22/24.
//

import UIKit

class UserScriptsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView       = UITableView()
    let reuseID         = "cellWithSubtitle"
    var scriptOptions   = [String]()
    
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
        print("custom script tapped")
    }

    
    // MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell                                    = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell                                        = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
        
        if #available(iOS 14.0, *) {
            var config                              = cell.defaultContentConfiguration()
            config.text                             = "description NEW in iOS 14"
            config.textProperties.font              = UIFont.systemFont(ofSize: 14)
            config.textProperties.color             = .black
            
            config.secondaryText                    = "the scriptz NEW in iOS 14"
            config.secondaryTextProperties.font     = UIFont.systemFont(ofSize: 10)
            config.secondaryTextProperties.color    = .gray
            
            cell.contentConfiguration               = config
            
        } else {
            print("else statement reached for cellz")
            cell.textLabel?.text                    = "description"
            cell.textLabel?.font                    = UIFont.systemFont(ofSize: 14)
            cell.textLabel?.textColor               = .black
            
            cell.detailTextLabel?.text              = "the script"
            cell.detailTextLabel?.font              = UIFont.systemFont(ofSize: 10)
            cell.detailTextLabel?.textColor         = .gray
            
        }
        
        return cell
    }
}
