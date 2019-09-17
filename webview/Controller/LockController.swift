import UIKit
import LocalAuthentication

class LockController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    
    // Sayfayı kapat
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func faceID() {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Uygulamaya giriş yapabilmeniz için TouchID ile giriş yapmalısınız ") { (isSuccess, error) in
                if isSuccess {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert()
                }
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Hatalı ID", message: "Çıkış yaptıktan sonra tekrar deneyebilirsiniz", preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "Çıkış yap",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        
                                        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                                               to: UIApplication.shared, for: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func configureUI() {
        
        view.backgroundColor = Theme.current.background
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "TouchID ile Giriş"
        navigationController?.navigationBar.barStyle = .black
        
        faceID()
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
        //            self.handleDismiss()
        //
        //
        //        })
        
    }
    
    
    
}
