
struct NotificationModel {
    
    var title: String
    var message: String
    var link: String?
    var timestamp: Int
    
    
    init?(title: String, message: String, link: String, timestamp: Int) {
        self.title = title
        self.message = message
        self.link = link
        self.timestamp = timestamp
    }
    
    
}
