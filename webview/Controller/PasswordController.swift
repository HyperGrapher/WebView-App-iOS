import UIKit


class PasswordController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        UserDefaults.standard.set(true, forKey: "isTouchIDSet") //
        UserDefaults.standard.set(true, forKey: "isAllowedToRun") //
        
        
    }
    
    
    // Sayfayı kapat
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func configureUI() {
        view.backgroundColor = Theme.current.background
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Şifre İşlemleri"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    
    
}
