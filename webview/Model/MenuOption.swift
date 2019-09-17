import UIKit

// Drawer menu itemleri
enum MenuOption: Int, CustomStringConvertible {
    
    case MainPage
    case Password
    case Notifications
    case Tema
    
    var description: String {
        switch self {
        case .MainPage: return "Ana Sayfa"
        case .Password: return "Şifre İşlemleri"
        case .Notifications: return "Bildirimler"
        case .Tema: return "Tema"
        }
    }
    
    var image: UIImage {
        switch self {
        case .MainPage: return UIImage(named: "ic_menu_home") ?? UIImage()
        case .Password: return UIImage(named: "ic_menu_password") ?? UIImage()
        case .Notifications: return UIImage(named: "ic_menu_notification") ?? UIImage()
        case .Tema: return UIImage(named: "ic_menu_theme") ?? UIImage()
        }
    }
}
