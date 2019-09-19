import UIKit

class ThemeView: UIView {

    // MARK: - Properties
    var isLightTheme: Bool = true
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Dark Tema / Light Tema "
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = isLightTheme
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return  switchControl
    }()
    
    
    // - - - - - - -- - -- - - -- - - - - - -- - - -
    
    
    let usernameLabel2: UILabel = {
        let label = UILabel()
        label.text = "Light Tema / Dark Tema"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    

    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserDefaults.standard.object(forKey: Constants.THEME_USER_DEFAULT_KEY) != nil {
            isLightTheme = UserDefaults.standard.bool(forKey:  Constants.THEME_USER_DEFAULT_KEY)
        }
        
        
        
        addSubview(usernameLabel)
        usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleSwitchAction(sender: UISwitch) {
        
        Theme.current = sender.isOn ? LightTheme() : DarkTheme()
        
        UserDefaults.standard.set(sender.isOn, forKey: Constants.THEME_USER_DEFAULT_KEY)
        
    }
    

    
    
}
