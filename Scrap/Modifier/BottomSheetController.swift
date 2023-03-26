//
//  HalfSheetController.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/19.
//

import Foundation
import SwiftUI

class BottomSheetController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
            presentationController.largestUndimmedDetentIdentifier = .medium
        }
    }
}

struct BottomSheet<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: () -> ()
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            //presenting modal view
            let sheetController = BottomSheetController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        }else {
            //closing view when showSheet toggled again
            uiViewController.dismiss(animated: true)
        }
    }
    
    //on dismiss
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: BottomSheet
        
        init(parent: BottomSheet) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

extension View {
    func bottomSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping() -> SheetView, onEnd: @escaping() -> ()) -> some View {
        return self
            .background(
                BottomSheet(sheetView: sheetView(), showSheet: showSheet, onEnd: onEnd)
            )
    }
}
