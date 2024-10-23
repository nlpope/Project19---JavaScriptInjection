//
//  UserScriptsVC.swift
//  Project19 - JavaScriptInjection
//
//  Created by Noah Pope on 10/22/24.
//

import UIKit

class UserScriptsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView       = UITableView()
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    @objc func addCustomScript() {
        print("custom script tapped")
    }

    
    // MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor    = .systemBackground
        
        return cell
    }
}
