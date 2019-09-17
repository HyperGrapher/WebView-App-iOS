import UIKit
import WebKit
import FirebaseDatabase
import FirebaseAuth

// Webviewden sorumlu HomeController
class HomeController: UIViewController, WKNavigationDelegate {
    
    var delegate: HomeControllerDelegate?
    var webView: WKWebView!
    var canGetParams = true
    
    // Firebase
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // touch id ile giriş aktif mi?
        let isTouchIDSet = UserDefaults.standard.bool(forKey: "isTouchIDSet")
        let isAllowedToRun = false  //UserDefaults.standard.bool(forKey: "isAllowedToRun")
        
        print(" - - - - - touch id is \(isTouchIDSet)")
        
        // Aktifse LockController'a git.
        if isAllowedToRun{
            print("-------------- touch id is set")
            let lockCont = LockController()
            present(UINavigationController(rootViewController: lockCont), animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "isAllowedToRun")
        } else {
            print("---------- Skipping touch id isTouchIDSet: \(isTouchIDSet)   -   isAllowedToRun: \(isAllowedToRun)")
        }
        
        view.backgroundColor = .white
        
        // Eğer firebase user yoksa oluştur
        createAnonymUserIfNotExist()
        
        configureNavigationBar()
        
        
        ref = Database.database().reference()
        
        
        // Database değişikliklerini dinle ve yeni linki aç
        ref.child("data/webViewLink").observe(.value) { (snapshot) in
            
            let link = snapshot.value as? String
            
            self.configureWebview(link: link!)
        }
        
        // NotificationController'dan gelen tıklamaları dinler
        // ve visitNotificationLink fonksiyonunu çalıştırır.
        NotificationCenter.default.addObserver(self, selector:
            #selector(visitNotificationLink), name: Notification.Name("notification_link"),
                                              object: nil)
        
        
    }
    
    // Eğer NotificationController'dan gelen tıklama varsa linki yükler.
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
        guard let myUrl = navigationAction.request.url, let scheme = myUrl.scheme, scheme.contains("http") else {
            decisionHandler(.cancel)
            return
        }
        
        // Eğer varsa URL parametrelerini al
        let params = URL(string: myUrl.absoluteString)!

        // parametereler içinde widget tanımlıysa geri kalan kodu işlet
        if let widgetParam: String = params["widget"]{
            
            let siteParam: String = params["site"]!
            
            // canGetParams:
            // Sayfa tekrar yüklendiğinde veya her ileri/geri navigasyonda
            // URL parametrelerini tekrar alıp Widget eklemeyi önler.
            // handleReload, handleForward, handleBackward methodlarında değeri false olarak değişir
            if canGetParams {
                print("- - - - - - - - - - - - - - - ")
                print(myUrl.absoluteString)
                print("Widget: \(widgetParam) | site: \(siteParam)")
            }
            
            // Her seferinde değeri true olarak resetle
            canGetParams = true
            
           

        }
        
        
        

        
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
                
                
                let uid: String? = authResult?.user.uid as String?
                print(uid!)
                self.saveUserToDatabase(uid: uid!)
                
            }
        }
        
        
        
        
    }
    
    // Yeni user oluşturulunca database'e uid'sini kaydet
    func saveUserToDatabase(uid: String){
        
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        ref.child("users").childByAutoId().setValue(["created": formattedDate ])
        
        
        
        
    }
    
    
    
    // Navigation bar
    func configureNavigationBar() {
        
        
        navigationController?.navigationBar.barTintColor = Constants.theme.getTheme()
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
        
    }
    
    // Exit app
    @objc func handleExit() {
        
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
        
    }
    
    
    @objc func handleReload() {
        canGetParams = false
        webView?.reload()
        
    }
    
    
    @objc func handleForward() {
        
        if webView.canGoForward {
            canGetParams = false
            webView?.goForward()
        }
        
    }
    
    
    @objc func handleBackward() {
        
        if webView.canGoBack {
            canGetParams = false
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

// URL parametrelerini ayırmak için gerekli extension
extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}
