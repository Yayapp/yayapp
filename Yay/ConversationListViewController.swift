import UIKit

class ConversationListViewController: ATLConversationListViewController, ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self

        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - ATLConversationListViewControllerDelegate Methods
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSelectConversation conversation:LYRConversation) {
        let controller = ConversationViewController(layerClient: self.layerClient)
        controller.conversation = conversation
        controller.displaysAddressBar = false
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSearchForText searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
        UserManager.sharedManager.queryForUserWithName(searchText) { (participants: NSArray?, error: NSError?) in
            if error == nil {
                if let callback = completion {
                    callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
                }
            } else {
                if let callback = completion {
                    callback(nil)
                }
                println("Error searching for Users by name: \(error)")
            }
        }
    }
    
    // MARK - ATLConversationListViewControllerDataSource Methods
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController, titleForConversation conversation: LYRConversation) -> String {
        return conversation.metadata["name"] as! String
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}