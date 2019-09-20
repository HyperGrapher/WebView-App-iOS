import UIKit

class FaceIDView: UIView {
    
    // MARK: - Properties
    var isFaceIdActive: Bool = false
    
    let faceIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Face ID ile giriş"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = isFaceIdActive
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return  switchControl
    }()
    
    

    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserDefaults.standard.object(forKey: Constants.FACEID_USER_DEFAULT_KEY) != nil {
            isFaceIdActive = UserDefaults.standard.bool(forKey:  Constants.FACEID_USER_DEFAULT_KEY)
        }
        
        
        
        addSubview(faceIDLabel)
        faceIDLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        faceIDLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleSwitchAction(sender: UISwitch) {
        
        print("__ FACE ID IS ON: \(sender.isOn)")
        UserDefaults.standard.set(sender.isOn, forKey: Constants.FACEID_USER_DEFAULT_KEY)
        
    }
    
    
    
    
}
