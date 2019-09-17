import UIKit

// Drawer menu'nün açılıp kapanmasından sorumlu Controller.
// Drawer menu item'lerine navigasyonu sağlar.
class ContainerController: UIViewController {
    
    var menuController: MenuController!
    var centerController: UIViewController!
    var isExpanded = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Drawer menu açılınca statusBar'ı saklar
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    // Status bar animasyon tercihi
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // Status barı isExpanded durumuna göre sakla veya göster
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    func configureHomeController() {
        let homeController = HomeController()
        homeController.delegate = self
        centerController = UINavigationController(rootViewController: homeController)
        
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    // Menu butonu diğer Controller içinde bulunuyor.
    // Menu ikonuna tıklanınca bu fonksiyon çalışır ve menu'yü açar.
    func configureMenuController() {
        if menuController == nil {
            
            menuController = MenuController()
            menuController.delegate = self
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
            
        }
    }
    
    func animatePanel(shouldExpand: Bool, menuOption: MenuOption?) {
        
        if shouldExpand {
            
            // Drawer menüyü göster
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = self.centerController.view.frame.width - 80
            }, completion: nil)
            
        } else {
            
            // Drawer menüyü sakla
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = 0
            }) { (_) in
                guard let menuOption = menuOption else { return }
                self.didSelectMenuOption(menuOption: menuOption)
            }
        }
        
        animateStatusBar()
        
    }
    
    // Drawer menu navigasyonunu sağlar.
    func didSelectMenuOption (menuOption: MenuOption) {
        switch menuOption {
        case .MainPage:
            print("Ana sayfaya git")
        case .Password:
            let passwordCont = PasswordController()
            present(UINavigationController(rootViewController: passwordCont), animated: true, completion: nil)
        case .Notifications:
            let notificaitonCont = NotificationController()
            present(UINavigationController(rootViewController: notificaitonCont), animated: true, completion: nil)
        case .Tema:
            let themeController = ThemeController()
            present(UINavigationController(rootViewController: themeController), animated: true, completion: nil)
        }
    }
    
    
}


extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle(forMenuOption menuOption: MenuOption?) {
       
        
        if !isExpanded {
            configureMenuController()
        }
        
        isExpanded = !isExpanded
        animatePanel(shouldExpand: isExpanded, menuOption: menuOption)
    }
    
    
    
}
