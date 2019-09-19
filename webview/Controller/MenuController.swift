
import UIKit
private let reuseIdentifer = "MenuOptionCell"

// Drawer Menuyü oluşturur.

class MenuController: UIViewController {
    
    var tableView: UITableView!
    var delegate: HomeControllerDelegate?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureTableView()
        
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
        
        return 4 // Kaç adet drawer menu itemi var belirler.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! MenuOptionCell
        
        // Model klasöründeki MenuOption dosyasında tanımlı
        // isimlerini her bir menü sırasına yazdırarak drawer menuyü oluşturur.
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.descriptionLabel.text = menuOption?.description
        cell.iconImageView.image = menuOption?.image
        cell.updateBackgroundColor() // Seçili temaya göre BG rengi verir
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
