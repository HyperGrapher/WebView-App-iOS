import UIKit
import FirebaseAuth
import FirebaseDatabase

class NotificationController: UITableViewController {
    
    var ref: DatabaseReference!
    var notificationList = [NotificationModel]()
    
    
    let cellID = "notificaitons"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        ref = Database.database().reference()
        
        getNotifications()
        
    }
    
    // Firebase DB'deki bildirimleri getir ve notificationList'e ekle
    func getNotifications() {
        
        
        let notificationsRef = ref.child("notifications")
        let queryRef = notificationsRef.queryOrdered(byChild: "timestamp")
        
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let title = snap.childSnapshot(forPath: "title").value as! String
                let message = snap.childSnapshot(forPath: "message").value as! String
                let link = snap.childSnapshot(forPath: "link").value as! String
                let timestamp = snap.childSnapshot(forPath: "timestamp").value as! Int
                
                let notifObj = NotificationModel(title: title , message: message , link: link , timestamp: timestamp )
                self.notificationList.append(notifObj!)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
            }
            
        })
        
        
    }
    
    
    
    
    // Sayfayı kapat
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // UI setup
    func configureUI() {
        
        tableView.register(UITableViewCell.self  , forCellReuseIdentifier: cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Bildirimler"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        
        
        cell.textLabel?.text = notificationList[indexPath.row].title // " \(indexPath.row)"
        cell.detailTextLabel?.text = notificationList[indexPath.row].message // " \(indexPath.row)"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link: String = notificationList[indexPath.row].link ?? ""
        if !link.isEmpty {
            
            if link.contains("http") {
                UserDefaults.standard.set(link, forKey: "link") // Linki userDefaults'a kaydet
                handleDismiss() // sayfayı kapat
                // HomeController içindeki listener'ı tetikler ve gönderilen link açılır.
                NotificationCenter.default.post(name: Notification.Name("notification_link"), object: nil)
                
            }
            
        }
    }
    
    
    
}
