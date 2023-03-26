//
//  ShareViewController.swift
//  Share
//
//  Created by 김영선 on 2022/09/21.
//

import UIKit
import Social
import SwiftUI
import Combine
import MobileCoreServices
import UniformTypeIdentifiers
import UserNotifications

struct NewDataModel: Decodable{ //자료 저장 -> response 데이터로 받을 link id
    struct Result: Decodable {
        var linkId: Int

        init(linkId: Int){
            self.linkId = linkId
        }
    }
    var code: Int
    var message: String
    var result: Result
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}

class ShareViewController: UIViewController{
    private var service = APIService()
    private var cancellable: AnyCancellable!
    
    private var catID = 0
    private var userIndex = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID")
    private var appURLString = "ScrapShareExtension://"
    private var webpageTitle : String = ""
    private var webpageUrl : String = ""
    private var webpageImageUrl : String = ""
    private var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userIndex != 0 {
            configureNavigationBar()
        }else {
            configureNavigationBarForLogin()
        }
        
        let delegate = CategoryIDDelegate()
        let childView = UIHostingController(rootView: ShareUIView(delegate: delegate))
        self.addChild(childView)
        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
        self.cancellable = delegate.$categoryID.sink { catID in
            self.catID = catID
        }
    }
    
    private func extractURL(){
        let extensionItems = extensionContext?.inputItems as! [NSExtensionItem]
        let title = extensionItems[0].attributedContentText?.string ?? ""
        for extensionItem in extensionItems {
            if let itemProviders = extensionItem.attachments {
                for itemProvider in itemProviders {
                    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                            let baseURL = url as! NSURL
                            print("url⭐️⭐️⭐️⭐️⭐️⭐️⭐️")
                            print(baseURL)
                            self.webpageTitle = title
                            self.webpageUrl = baseURL.absoluteString ?? ""
                            self.webpageImageUrl = ""
                            self.addNewData(catID: self.catID, userIndex: self.userIndex!)
                        }
                    }
                    if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
                        itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { (result, error) in
                            let text = result as! String
                            print("plain_text⭐️⭐️⭐️⭐️⭐️⭐️⭐️")
                            print(text)
                            if text.hasPrefix("https") || text.hasPrefix("http") { //youtube
                                self.webpageTitle = title
                                self.webpageUrl = text
                                self.webpageImageUrl = ""
                                self.addNewData(catID: self.catID, userIndex: self.userIndex!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func configureNavigationBarForLogin() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelAction))
        self.navigationItem.setRightBarButton(doneButton, animated: false)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    //set the title and the navigation items
    private func configureNavigationBar(){
        self.navigationItem.title = "자료 저장"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        self.navigationItem.leftBarButtonItem?.tintColor = .systemBlue
        let postButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postAction))
        self.navigationItem.setRightBarButton(postButton, animated: false)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    //define the actions for the navigation items - cancel
    @objc private func cancelAction(){
        let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
        extensionContext?.cancelRequest(withError: error)
    }
    
    //url, imageUrl, title 모두 javascript 파일에서 따올 수 있음
    @objc private func postAction(){
        print("post")
        //URL, Title, ImageURL 가져오기
        let extensionItems = extensionContext?.inputItems as! [NSExtensionItem]
        for extensionItem in extensionItems {
            if let itemProviders = extensionItem.attachments {
                for itemProvider in itemProviders {
                    let propertyList = UTType.propertyList.identifier
                    if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
                        itemProvider.loadItem(forTypeIdentifier: propertyList, completionHandler: { (result, error) in
                            guard let dictionary = result as? NSDictionary,
                                  let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                                  let title = results["currentTitle"] as? String,
                                  let hostname = results["currentUrl"] as? String,
                                  let imageURL = results["images"] as? String else {
                                return
                            }
                            self.webpageTitle = title
                            self.webpageUrl = hostname
                            self.webpageImageUrl = imageURL
                            self.addNewData(catID: self.catID, userIndex: self.userIndex!)
                            self.flag = true
                        })
                    }else {
                        print("💥💥💥hasItemConformingToTypeIdentifier(propertyList) 없음...")
                    }
                }
            }else {
                print("💥💥💥itemProviders = extensionItem.attachments 부분 문제")
            }
        }
        if !flag {
            extractURL()
        }
    }
    
    func setNotification() -> Void {
        let manager = LocalNotificationManager()
        manager.requestPermission() //알림 권한 요청
        manager.addNotification(title: "Scrap") //notification 추가
        manager.schedule(title: webpageTitle)
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func addNewData(catID: Int, userIndex: Int){
        guard let url = URL(string: "https://scrap-j2kb.shop/data?id=\(userIndex)&category=\(catID)") else {
            print("invalid url")
            return
        }
        
        let link = self.webpageUrl
        let title = self.webpageTitle
        let imageUrl = self.webpageImageUrl
        
        let body: [String: Any] = ["link" : link, "title" : title, "imgUrl" : imageUrl]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.addDataToScrapCompletionHandler(withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    self.setNotification() //자료 저장이 되면, 푸시 알람 뜨도록 notification 세팅
                    break
                }
            }
        }
    }
}

@objc(ShareNavigationController)
class ShareNavigationController: UINavigationController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setViewControllers([ShareViewController()], animated: false)
    }
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
