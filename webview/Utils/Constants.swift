import Foundation
import UIKit

struct Constants {
    
    struct theme {
        static let main1: UIColor  = .blue
        static let theme_user_default = "themeSelection"
        
        init() {
            let themeDefault = UserDefaults.standard.bool(forKey: Constants.theme.theme_user_default)
            print(" - -  THEME: \(themeDefault)")
        }
        
        static func getTheme() -> UIColor {
            
            return main1
        }
        
        
        /**
        
        static func getTheme() -> [UIColor] {
            
            var colors = [UIColor]()
            
            colors.append(main1)
            
            return colors
        }
        
        
        */
      
        
    }
    
    
    
}
