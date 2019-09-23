//
//  TodayViewController.swift
//  widget
//
//  Created by burak mestan on 19.09.2019.
//  Copyright © 2019 burak mestan. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    
    let cellID = "widget"
    var widgetList = [Widget]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getSavedWidgets()
        configureUI()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func getSavedWidgets() {
        
        let fetchRequest: NSFetchRequest<Widget> =  Widget.fetchRequest()
        
        do {
            widgetList = try PersistanceService.context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch  {
            
        }
        
        
        print("-- Start Widget List")
        for it in widgetList {
            if let item = it.name {
                print(item)
            }
            
        }
        print("-- END Widget List")
        
    }
    
    
    // UI setup
    func configureUI() {
        
        tableView.register(UITableViewCell.self  , forCellReuseIdentifier: cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return widgetList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        
        
        cell.textLabel?.text = widgetList[indexPath.row].name?.uppercased()
        
        return cell
    }
    
    
    
    

}
