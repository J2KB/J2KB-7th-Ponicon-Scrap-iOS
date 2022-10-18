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
    private var cancellable: AnyCancellable!
    private var catID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray6
        configureNavBar()
        
        let delegate = CategoryIDDelegate()
        let childView = UIHostingController(rootView: ShareUIView(delegate: delegate))
        //이 view controller가 열릴 때, categoryList를 받아와야 함
        self.addChild(childView)
        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
        
        self.cancellable = delegate.$categoryID.sink { catID in
            print(catID)
            self.catID = catID
        }
    }
    
    //2: set the title and the navigation items
    private func configureNavBar(){
        self.navigationItem.title = "자료 저장"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        let postButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postAction))
        self.navigationItem.setRightBarButton(postButton, animated: false)
    }
    
    //3. define the actions for the navigation items - cancel
    @objc private func cancelAction(){
        let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
        extensionContext?.cancelRequest(withError: error)
    }

    //4. define the actions for the navigation items - done/post
    @objc private func postAction(){
        print("post")
        //get the itemProvider which wraps the url we need
        let item : NSExtensionItem = self.extensionContext?.inputItems[0] as! NSExtensionItem
        print(item)
        let itemProvider: NSItemProvider = item.attachments?[0] as! NSItemProvider
        print(itemProvider)
        
        //pull the url out
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                let baseURL = url as! NSURL
                print(baseURL)
                self.addNewData(baseurl: baseURL.absoluteString!, catID: self.catID)
                //request to server with this base url
            }
        }
        //default stubbed out code which can pass data back to the host app.
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func addNewData(baseurl: String, catID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data?id=2&category=\(catID)") else {
            print("invalid url")
            return
        }

        let baseURL = baseurl
        
        let body: [String: Any] = ["baseURL" : baseURL]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NewDataModel.self, from: data)
                    print(result)
                    print("post saving data : SUCCESS")
                    print(catID)
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
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
