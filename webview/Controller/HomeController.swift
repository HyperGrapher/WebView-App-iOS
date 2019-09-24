import UIKit
import WebKit
import FirebaseDatabase
import FirebaseAuth
import CoreData

// Webviewden sorumlu HomeController
class HomeController: UIViewController, WKNavigationDelegate {
    
    var delegate: HomeControllerDelegate?
    var webView: WKWebView!
    var canGetParams = true
    
    var homeLink: String?
    
    // Firebase
    var ref: DatabaseReference!
    
    var widgetList = [Widget]()
    var nameList = [String]()
    
    var activityView: UIActivityIndicatorView?
    var container: UIView?
    
    var userID: String?
    
    private var loadingObservation: NSKeyValueObservation?
    
    // Loading indicator
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        return spinner
    }()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        configureNavigationBar()
      
        getSavedWidgets()
        
        faceIDCheck()
        
        createAnonymUserIfNotExist()
        
        getFirebaseLink()
        
        setupObservers()
        
    }
    
    func getFirebaseLink() {
        
        ref = Database.database().reference()
        
        
        // Database değişikliklerini dinle ve yeni linki aç
        ref.child("data/webViewLink").observe(.value) { (snapshot) in
            
            let link = snapshot.value as? String
            self.homeLink = link
            self.configureWebview(link: link!)
        }
        
    }
    
    
    func setupView() {
        
        view.backgroundColor = Theme.current.background
        
        webView = WKWebView()
        webView.navigationDelegate = self

        view = webView

        
        // Loading Indicator methodu
        loadingObservation = webView.observe(\.isLoading, options: [.new, .old]) { [weak self] (_, change) in
            guard let strongSelf = self else { return }
            
            let new = change.newValue!
            let old = change.oldValue!
            
            if new && !old {
                strongSelf.view.addSubview(strongSelf.loadingIndicator)
                strongSelf.loadingIndicator.startAnimating()
                NSLayoutConstraint.activate([strongSelf.loadingIndicator.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor),
                                             strongSelf.loadingIndicator.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor)])
                strongSelf.view.bringSubviewToFront(strongSelf.loadingIndicator)
            }
            else if !new && old {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.loadingIndicator.removeFromSuperview()
            }
        }
        
        
        
    }
    
    
    func faceIDCheck() {
        // touch id ile giriş aktif mi?
        let isTouchIDSet = UserDefaults.standard.bool(forKey: Constants.FACEID_USER_DEFAULT_KEY)
        
        // Aktifse LockController'a git.
        if isTouchIDSet{
            let lockCont = LockController()
            present(UINavigationController(rootViewController: lockCont), animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "isAllowedToRun")
        }
        
        
        
    }

    // Cookie hatırlama methodu
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url else {
                decisionHandler(.cancel)
                return
        }
        
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { cookie in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        decisionHandler(.allow)
    }
    
    // Eğer NotificationController'dan veya WidgetController'dan gelen tıklama varsa linki yükler.
    @objc func visitLink (notification: NSNotification){
        
        let link = UserDefaults.standard.string(forKey: "link") ?? ""
        configureWebview(link: link)
        // Link alındıktan sonra silinebilir.
        UserDefaults.standard.set("", forKey: "link")
        
    }
    
    // Eğer NotificationController'dan veya WidgetController'dan gelen tıklama varsa linki yükler.
    @objc func visitHome (notification: NSNotification){
        configureWebview(link: homeLink!)
    }
    
    
    func configureWebview(link: String) {

        if !link.isEmpty {
            
            let url = URL(string: link)
            let request = URLRequest(url: url!)
            
            webView?.load(request)
            
        }

    }
    
    // Tıklanan URL'leri sapta ve ilgili methodu çağır.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // link yazım hatalarından kaynaklı çökmeleri engellemek için,
        // linkler http veya https ile başlamalı
        guard let myUrl = navigationAction.request.url, let scheme = myUrl.scheme, scheme.contains("http") else {
            decisionHandler(.cancel)
            return
        }
        
        // Eğer URL içinde yenisekme geçiyorsa default browser ile aç
        if myUrl.absoluteString.contains("yenisekme"){
            UIApplication.shared.open(myUrl)
        }
        
        // Eğer varsa URL parametrelerini al
        let params = URL(string: myUrl.absoluteString)!

        // parametereler içinde widget tanımlıysa geri kalan kodu işlet
        if let actionParam: String = params["widget"]{
            
            if let siteParam: String = params["site"] {
                
                
                // canGetParams:
                // Sayfa tekrar yüklendiğinde veya her ileri/geri navigasyonda
                // URL parametrelerini tekrar alıp Widget eklemeyi önler.
                // handleReload, handleForward, handleBackward methodlarında değeri false olarak değişir
                if canGetParams {
                    saveWidget(action: actionParam, siteName: siteParam, url: myUrl.host!)
                }
                
               
            }
        
            // Her seferinde değeri true olarak resetle
             canGetParams = true
           

        }
        
        decisionHandler(.allow)
        
    }
    
    
    var currentSite = ""
    func saveWidget(action: String, siteName: String, url: String) {
        

        // Bazı siteler mobil siteye yönlendiriyor, iki kez aynı sayfa çağrılmış oluyor
        // Aynı parametrelerle iki kez çağırmayı engellemek için önceki site ismi ile kontrol ediyoruz.
        if currentSite != siteName {
            
            print("Adding -> Widget: \(action) | site: \(siteName) url:\(url)")
            currentSite = siteName
            
            // Eğer hali hazırda site ismi kayıtlı değilse DB'ye ekle
            if !nameList.contains(siteName){
                let widget = Widget(context: PersistanceService.context)
                widget.name = siteName
                widget.url = url
                PersistanceService.saveContext()
                getSavedWidgets()
            }
            
     
        }
        
        
    }
    
    func getSavedWidgets() {
        let fetchRequest: NSFetchRequest<Widget> =  Widget.fetchRequest()
    
        do {
            widgetList = try PersistanceService.context.fetch(fetchRequest)
            
        } catch  {
            
        }
        
        
        for it in widgetList {
            if let item = it.name {
                nameList.append(item)
            }
            
        }
        
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
                self.saveUserToDatabase(uid: uid!)
                
            }
        } else {
           userID = Auth.auth().currentUser?.uid
        }
        
        
        
        
    }
    
    // Yeni user oluşturulunca database'e uid'sini kaydet
    func saveUserToDatabase(uid: String){
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        ref.child("users/\(uid)").setValue(["created": formattedDate ])
        
        
    }
    
    func setupObservers() {
        // Ana Sayfa'ya tıklanınca bu observer ile firebase linki açılır
        NotificationCenter.default.addObserver(self, selector:
            #selector(visitHome), name: Notification.Name("visitHome"),
                                  object: nil)
        
        // NotificationController'dan veya WidgetController'dan gelen tıklamaları dinler
        // ve visitNotificationLink fonksiyonunu çalıştırır.
        NotificationCenter.default.addObserver(self, selector:
            #selector(visitLink), name: Notification.Name(Constants.VISIT_URL),
                                  object: nil)
    }
    
    
    
    // Navigation bar
    func configureNavigationBar() {
        
        
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        navigationController?.navigationBar.barStyle = .black
        
        
        // Drawer Menu Icon - SOL taraf
        let drawerMenuIcon:UIBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "web_icons").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        
        
        // Webview ikonları - SAĞ taraf
        
        let refreshIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_refresh").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleReload))
        
        
        let exitIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleExit))
        
        
        let forwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_forward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleForward))
        
        
        let backwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_backward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBackward))
        
        let homeIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu_home").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleHome))

        
        // Sağdaki ikonları ekle
        navigationItem.setRightBarButtonItems([exitIcon, refreshIcon, forwardIcon, backwardIcon, homeIcon ], animated: true)
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
    
    
    
    @objc func handleHome() {
        
        if homeLink != nil {
            configureWebview(link: homeLink!)

        }
        
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
        
        
    }
    
    // Tema değiştiğinde renkeri güncelle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = Theme.current.background
        navigationController?.navigationBar.barTintColor = Theme.current.tint
        
    }
    
    
}

// URL parametrelerini ayırmak için gerekli extension
extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}
