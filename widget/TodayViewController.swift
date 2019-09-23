import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NCWidgetProviding {
    
    
    let cellID = "widget"
    var widgetList = [Widget]()
    
    let list = ["Google", "Twitter", "Facebook", "Instagram", "Reddit", "Burak"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white    
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func getSavedWidgets() {

        
    }
    
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        
        
        cell.textLabel?.text =  list[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(list[indexPath.row])
    }
    
    
    
    

}
