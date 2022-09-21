//
//  ShareViewController.swift
//  Share
//
//  Created by 김영선 on 2022/09/21.
//

import UIKit
import Social

class ShareViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1: set the background and call the function to create the navigation bar
        self.view.backgroundColor = .systemGray6
        configureNavBar()
        configureViews()
    }
    
    //2: set the title and the navigation items
    private func configureNavBar(){
        self.navigationItem.title = "scrap"
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
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    //5. set the ui components
    private func configureViews(){
        self.view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    //6. set the UITextField
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "hello"
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 12
        return textField
    }()
    
//    private lazy var categoryPicker: UIPickerView = {
//        let picker = UIPickerView()
//
//    }()
    
}

@objc(ShareNavigationController)
class ShareNavigationController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //2: set the viewcontrollers
        self.setViewControllers([ShareViewController()], animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
