import UIKit
import WebKit
import FirebaseDatabase
import FirebaseAuth

// Webviewden sorumlu HomeController
class HomeController: UIViewController, WKNavigationDelegate {
    
    var delegate: HomeControllerDelegate?
    var webView: WKWebView!
    
    
    // Firebase
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        createAnonymUserIfNotExist()
        
        configureNavigationBar()
        
        
        ref = Database.database().reference()
        
        
        // Database değişikliklerini dinle ve yeni linki aç
        ref.child("data/webViewLink").observe(.value) { (snapshot) in
            
            let link = snapshot.value as? String
            
            self.configureWebview(link: link!)
        }
        
        // Bildirimler sayfasından gelen tıklamaları dinler
        NotificationCenter.default.addObserver(self, selector:
            #selector(visitNotificationLink), name: Notification.Name("notification_link"),
                                              object: nil)
        
        
    }
    
    // Eğer bidlrim sayfasından gelen tıklama varsa linki yükler.
    @objc func visitNotificationLink (notification: NSNotification){
        let link = UserDefaults.standard.string(forKey: "link") ?? ""
        configureWebview(link: link)
        // Link alındıktan sonra silinebilir.
        UserDefaults.standard.set("", forKey: "link")
        
    }
    
    
    
    func configureWebview(link: String) {
        
        let url = URL(string: link)
        let request = URLRequest(url: url!)
        
        if webView == nil {
            webView = WKWebView()
            webView.navigationDelegate = self
            view = webView
        }
        
        
        webView?.load(request)
        
        
        
        
    }
    
    // Tıklanan URL'leri sapta ve ilgili methodu çağır.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // link yazım hatalarından kaynaklı çökmeleri engellemek için,
        // linkler http veya https ile başlamalı
        guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
            decisionHandler(.cancel)
            return
        }
        
        
        
        print("----------------- *******: ", url)
        decisionHandler(.allow)
        
        
    }
    
    
    
    
    func createAnonymUserIfNotExist(){
        
        // Eğer anonym user oluşturunmamışsa yeni user oluştur
        if Auth.auth().currentUser == nil {
            
            Auth.auth().signInAnonymously() { (authResult, error) in
                
                if let err = error {
                    print("-------------  Failed to sign in anonymously  -------------", err)
                    return
                }
                
                print("-------------  USER CREATED  -------------------")
                
                let uid: String? = authResult?.user.uid as String?
                print(uid!)
                self.saveUserToDatabase(uid: uid!)
                
            }
        } else {
            print("-------------  already signed in  -------------------")
        }
        
        
        
        
    }
    
    // Yeni user oluşturulunca database'e uid'sini kaydet
    func saveUserToDatabase(uid: String){
        
        print("-------------  SAVING USER  -------------------")
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        ref.child("users").childByAutoId().setValue(["created": formattedDate ])
        
        
        
        
    }
    
    
    
    // Navigation bar
    func configureNavigationBar() {
        
        
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.barStyle = .black
        
        
        // Drawer Menu Icon - SOL taraf
        let drawerMenuIcon:UIBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "web_icons").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        
        
        // Webview ikonları - SAĞ taraf
        
        let refreshIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_refresh").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleReload))
        
        
        let exitIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleExit))
        
        
        let forwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_forward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleForward))
        
        
        let backwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_backward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBackward))
        
        
        // Sağdaki ikonları ekle
        navigationItem.setRightBarButtonItems([exitIcon, refreshIcon, forwardIcon, backwardIcon ], animated: true)
        // Soldaki ikonları ekle
        navigationItem.setLeftBarButtonItems([drawerMenuIcon], animated: true)
        
        
    }
    
    
    
    // Toolbar action ikonları için methodlar
    
    // Drawer menu toggle
    @objc func handleMenuToggle() {
        delegate?.handleMenuToggle(forMenuOption: nil)
        
        print("test 1")
        
    }
    
    // Exit app
    @objc func handleExit() {
        
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
        
    }
    
    
    @objc func handleReload() {
        
        webView?.reload()
        
    }
    
    
    @objc func handleForward() {
        
        if webView.canGoForward {
            webView?.goForward()
        }
        
    }
    
    
    @objc func handleBackward() {
        
        if webView.canGoBack {
            webView?.goBack()
        }
        
        // TODO: Test sırasında firebase user'ı silmek için
        // Kaldırılacak
        
        /**
         
         do{
         try Auth.auth().signOut()
         print("----------  USER DELETED  -------------")
         }catch{
         
         }
         
         */
        
        
    }
    
    
    
    
}

