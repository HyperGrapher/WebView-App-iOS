import UIKit
import CoreData


class WidgetController: UITableViewController {
    
    
    let cellID = "widget"
    var widgetList = [Widget]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        getSavedWidgets()
        
    }
    
    func getSavedWidgets() {
        
        let fetchRequest: NSFetchRequest<Widget> =  Widget.fetchRequest()
        
        do {
            widgetList = try PersistanceService.context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch  { }
        
    }
    
    
    // Sayfayı kapat
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)

    }
    
    // UI setup
    func configureUI() {
        
        tableView.register(UITableViewCell.self  , forCellReuseIdentifier: cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        view.backgroundColor = Theme.current.background
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Kayıtlı siteler"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return widgetList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        
        
        cell.textLabel?.text = widgetList[indexPath.row].name?.uppercased()
        
        //create a button or any UIView and add to subview
        let button=UIButton.init(type: .system)
        button.setTitle("Sil", for: .normal)
        button.tintColor = UIColor.red
        button.frame.size = CGSize(width: 100, height: 50)
        cell.addSubview(button)
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(deleteWidget(_:)), for: .touchUpInside) // Button tıklandığında widget'i sil

        //set constrains
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            button.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            button.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        } else {
            button.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
            button.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        }
        
        
        return cell
    }
    
    
    @objc func deleteWidget (_ sender:UIButton) {
        let buttonRow = sender.tag
        let deletedWidget: Widget = widgetList.remove(at: buttonRow)
        PersistanceService.context.delete(deletedWidget)
        PersistanceService.saveContext()
        getSavedWidgets()
        
    }
    
    
    
    // Tıklama olunca Link varsa webview ile aç
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
  
        var link: String = widgetList[indexPath.row].url ?? ""
        
        print(link)
        if !link.isEmpty {
            
            // linkin başında http yoksa ekle.
            if !link.contains("http") {
                link = "http://\(link)"
            }
            
            UserDefaults.standard.set(link, forKey: "link") // Linki userDefaults'a kaydet
            handleDismiss() // sayfayı kapat
            // HomeController'daki listener'ı tetikler ve userDefaults ile gönderilen link açılır.
            NotificationCenter.default.post(name: Notification.Name(Constants.VISIT_URL), object: nil)
                            
        }
    }
    
    
    
}

