import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.webviewapp")
        storeURL = storeURL?.appendingPathComponent("webview.sqlite")
        return storeURL!
    }
    
}
