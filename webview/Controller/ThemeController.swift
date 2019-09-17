import UIKit

class ThemeController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    // Sayfayı kapat
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func configureUI() {
        
        view.backgroundColor = Theme.current.background
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tema Ayarları"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
        
        
        let frame = CGRect(x: 0, y:150, width: view.frame.width, height: 100)
        let themeView = ThemeView(frame: frame)
        view.addSubview(themeView)
        
        
    }
    
}


