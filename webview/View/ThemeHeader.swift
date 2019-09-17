
import UIKit

class ThemeHeader: UIView {

    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tema Ayarlarını aşağıdan değiştirebilirsiniz"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let profileImageDimension: CGFloat = 60
//
//        addSubview(profileImageView)
//        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
//        profileImageView.layer.cornerRadius = profileImageDimension / 2
        
        addSubview(usernameLabel)
        usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
