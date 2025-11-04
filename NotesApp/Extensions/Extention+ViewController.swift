//
//  Extention+ViewController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import Foundation
import UIKit

extension UIViewController {
    @discardableResult
    func addTopView(title: String, actionImageName: String? = nil, actionTarget: Any? = nil, actionSelector: Selector? = nil) -> TopView {
        
        var actionButton: UIButton? = nil
        
        if let imageName = actionImageName, let target = actionTarget, let selector = actionSelector {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
            button.tintColor = .label
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(target, action: selector, for: .touchUpInside)
            actionButton = button
        }
        let headerView = TopView(actionbutton: actionButton)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.title = title
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])
        return headerView
    }
    
    func presentError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
    }
}
