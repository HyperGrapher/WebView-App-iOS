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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var widgetList = [Widget]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         someOtherFunction()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func someOtherFunction() {
        // get the managed context
        let fetchRequest: NSFetchRequest<Widget> =  Widget.fetchRequest()
        
        
        do {
            widgetList = try PersistanceService.context.fetch(fetchRequest)
            
        } catch  {
            
        }
        
        
        print("-- Start Widget List")
        for it in widgetList {
            if let item = it.name {
                print(item)
                myLabel.text = item
            }
            
        }
        print("-- END Widget List")
        // have fun
    }
  
