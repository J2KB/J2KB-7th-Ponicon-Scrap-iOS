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
    private var webpageImageUrl : String = "https://miro.medium.com/max/371/1*i6ZmTpc6iiQyWACDpn6UIw.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard userIndex != 0 else {
            self.openMainApp()
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        configureNavBar()
        let delegate = CategoryIDDelegate()
        let childView = UIHostingController(rootView: ShareUIView(delegate: delegate))
        self.addChild(childView)
        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
        self.cancellable = delegate.$categoryID.sink { catID in
            print(catID)
            self.catID = catID
        }
    }
    
    @objc func openURL(_ url: URL) -> Bool { //create custom OpenURL
        var responder : UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

    private func openMainApp() { //open the containing app
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: self.appURLString) else { return }
            _ = self.openURL(url)
        })
    }
    
    //2: set the title and the navigation items
    private func configureNavBar(){
        self.navigationItem.title = "자료 저장"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        self.navigationItem.leftBarButtonItem?.tintColor = .systemBlue
        let postButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postAction))
        self.navigationItem.setRightBarButton(postButton, animated: false)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    //3. define the actions for the navigation items - cancel
    @objc private func cancelAction(){
        let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
        extensionContext?.cancelRequest(withError: error)
    }

    //4. define the actions for the navigation items - done/post
    @objc private func postAction(){
        print("post")
        //URL, Title, ImageURL 가져오기
        if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem {
            let propertyList = UTType.propertyList.identifier
            print(propertyList)
            for attachment in extensionItem.attachments! where attachment.hasItemConformingToTypeIdentifier(propertyList) {
                attachment.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                    guard let dictionary = item as? NSDictionary,
                          let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                          let title = results["currentTitle"] as? String,
                          let hostname = results["currentUrl"] as? String,
                          let image = results["images"] as? String else { return }
                    self.webpageTitle = title
                    self.webpageUrl = hostname
                    self.webpageImageUrl = image
                    self.addNewData(catID: self.catID, userIndex: self.userIndex!)
                }
            )}
        }
        //default stubbed out code which can pass data back to the host app.
//        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func displayUIAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> () in
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addNewData(catID: Int, userIndex: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=\(userIndex)&category=\(catID)") else {
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
                    self.displayUIAlertController(title: "자료 저장", message: "자료가 성공적으로 저장되었습니다.")
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
        //1: set the viewcontrollers
        self.setViewControllers([ShareViewController()], animated: false)
    }
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
