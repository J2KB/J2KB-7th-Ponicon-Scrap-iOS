//
//  ShareViewController.swift
//  Share
//
//  Created by 김영선 on 2022/09/21.
//

import UIKit
import Social
import SwiftUI

class ShareViewController: UIViewController{
    let childView = UIHostingController(rootView: ShareUIView())

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray6
        configureNavBar()
        
        //이 view controller가 열릴 때, categoryList를 받아와야 함
        self.addChild(childView)
        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
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
                var baseURL = url as! NSURL
                print(baseURL)
                //request to server with this base url
            }
        }
        //default stubbed out code which can pass data back to the host app.
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
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
