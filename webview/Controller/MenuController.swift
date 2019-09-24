
import UIKit
import FirebaseDatabase
import FirebaseAuth

private let reuseIdentifer = "MenuOptionCell"

// Drawer Menuyü oluşturur.

class MenuController: UIViewController {
    
    var tableView: UITableView!
    var delegate: HomeControllerDelegate?
    
    var ref: DatabaseReference!
    var count: UInt? = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = Database.database().reference()
        getNotifications()
        
        configureTableView()
        
 
        
    }
    
    func getNotifications() {
        
        guard let userId = Auth.auth().currentUser?.uid else {return}
        

        let notificationsRef = ref.child("users/\(userId)/badge")
        let queryRef = notificationsRef.queryOrdered(byChild: "message")
        
        
        queryRef.observe(.value, with: { snapshot in
            
            self.count = snapshot.childrenCount
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
                    
        })
        
        
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MenuOptionCell.self, forCellReuseIdentifier: reuseIdentifer)
        tableView.backgroundColor = Theme.current.tintDarker
        tableView.separatorStyle = .none
        tableView.rowHeight = 80 // Herbir drawer menu iteminin yüksekliği
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
}

extension MenuController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5 // Kaç adet drawer menu itemi var belirler.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! MenuOptionCell
        
        // Model klasöründeki MenuOption dosyasında tanımlı
        // isimlerini her bir menü sırasına yazdırarak drawer menuyü oluşturur.
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.descriptionLabel.text = menuOption?.description
        cell.iconImageView.image = menuOption?.image
        cell.updateBackgroundColor() // Seçili temaya göre BG rengi verir
        
        // Eğer menu itemi "bildirimler" ise bildirim sayısını göster
        if  menuOption?.description == Constants.MENU_NOTIFICATIONS {
            
            // Bildirim sayısı 0 değilse göster
            if count != 0 {
                cell.notificaitonLabel.text = "\(count!)"
            } else {
                // Sıfır ise boş string
                cell.notificaitonLabel.text = ""
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = MenuOption(rawValue: indexPath.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
    
    // seçili temaya göre menu renklerini ver
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        view.backgroundColor = Theme.current.background
        tableView.backgroundColor = Theme.current.tintDarker
        tableView.reloadData()
    }
    
    
}
