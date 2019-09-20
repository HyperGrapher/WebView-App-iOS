import UIKit

// Drawer menu itemleri
enum MenuOption: Int, CustomStringConvertible {
    
    case MainPage
    case Password
    case Notifications
    case Tema
    case Widget
    
    var description: String {
        switch self {
        case .MainPage: return Constants.MENU_MAIN
        case .Password: return Constants.MENU_PASSWORD
        case .Notifications: return Constants.MENU_NOTIFICATIONS
        case .Tema: return Constants.MENU_TEMA
        case .Widget: return Constants.MENU_WIDGET
        }
    }
    
    var image: UIImage {
        switch self {
        case .MainPage: return UIImage(named: "ic_menu_home") ?? UIImage()
        case .Password: return UIImage(named: "ic_menu_password") ?? UIImage()
        case .Notifications: return UIImage(named: "ic_menu_notification") ?? UIImage()
        case .Tema: return UIImage(named: "ic_menu_theme") ?? UIImage()
        case .Widget: return UIImage(named: "ic_menu_widget") ?? UIImage()
        
        }
    }
}
