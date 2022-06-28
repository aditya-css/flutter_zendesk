import Flutter
import UIKit
import ZendeskCoreSDK
import SupportProvidersSDK
import AnswerBotProvidersSDK
import ChatProvidersSDK
import MessagingSDK
import MessagingAPI
import ChatSDK
import SupportSDK
import AnswerBotSDK

public class SwiftZendeskSupportPlugin: NSObject, FlutterPlugin {
    
    var chatConfiguration: ChatConfiguration?
    var chatAPIConfiguration: ChatAPIConfiguration?
    var enablePreChatForm: Bool = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_support", binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskSupportPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let dic = call.arguments as? Dictionary<String, String>
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initialize":
            if(dic != nil) {
                initialize(dictionary: dic!)
                result(true)
            } else {
                result(false)
            }
        case "setVisitorInfo":
            if(dic != nil) {
                setVisitorInfo(dictionary: dic!)
                result(true)
            } else {
                result(false)
            }
        case "startChat":
            do {
                try startChat()
            } catch _ {
//                 os_log("error:")
            }
            result(true)
        case "resetUserIdentity":
            resetUserIdentity()
            result(true)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    func initialize(dictionary: Dictionary<String, String>) {
        guard let zendeskUrl =  dictionary["zendeskUrl"],
                let appId = dictionary["appId"],
                let oauthClientId = dictionary["oauthClientId"],
                let chatAccountKey = dictionary["chatAccountKey"],
                let shouldAskUserDetails = dictionary["shouldAskUserDetails"]
        else { return }
        enablePreChatForm = Bool.init(shouldAskUserDetails) ?? false
        Zendesk.initialize(appId: appId, clientId: oauthClientId, zendeskUrl:zendeskUrl)
        Support.initialize(withZendesk: Zendesk.instance)
        AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
        Chat.initialize(accountKey: chatAccountKey)
        initChatConfig()
    }
    
    func setVisitorInfo(dictionary: Dictionary<String, String>){
        var email = ""
        var name = ""
        var phoneNumber = ""

        if (enablePreChatForm) {
            chatConfiguration?.isPreChatFormEnabled = true
            chatConfiguration?.preChatFormConfiguration = ChatFormConfiguration(name: .required,
                                                                           email: .required,
                                                                           phoneNumber: .required,
                                                                           department: .hidden)
           Zendesk.instance?.setIdentity(Identity.createAnonymous())
        } else {
            chatConfiguration?.isPreChatFormEnabled = false
            chatConfiguration?.preChatFormConfiguration = ChatFormConfiguration(name: .hidden,
                                                                           email: .hidden,
                                                                           phoneNumber: .hidden,
                                                                           department: .hidden)
            email = dictionary["email"] ?? ""
            name = dictionary["name"] ?? ""
            phoneNumber = dictionary["phoneNumber"] ?? ""
            chatAPIConfiguration?.visitorInfo = VisitorInfo(name: name, email: email, phoneNumber: phoneNumber)
            let identity = Identity.createAnonymous(name: name, email: email)
            Zendesk.instance?.setIdentity(identity)
            Chat.instance?.configuration = chatAPIConfiguration!
        }
    }
    
    func startChat() throws {
        let answerBotEngine = try AnswerBotEngine.engine()
        let supportEngine = try SupportEngine.engine()
        let chatEngine = try ChatEngine.engine()
        let viewController = try Messaging.instance.buildUI(engines: [answerBotEngine, supportEngine,chatEngine],
                                                           configs: [chatConfiguration!])
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: viewController);
    }
    
    func presentViewController(rootViewController: UIViewController?, view: UIViewController) {
        if (rootViewController is UINavigationController) {
            (rootViewController as! UINavigationController).pushViewController(view, animated: true)
        } else {
            let navigationController: UINavigationController! = UINavigationController(rootViewController: view)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func initChatConfig() {
        if (chatConfiguration == nil && chatAPIConfiguration == nil) {
            chatConfiguration = ChatConfiguration()
            chatAPIConfiguration = ChatAPIConfiguration()
        }
    }

    func resetUserIdentity() {
        Chat.instance?.resetIdentity {}
    }
  }

