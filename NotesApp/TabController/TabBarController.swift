//
//  TabBarController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import UIKit

class TabBarController: UITabBarController {
    
    let roundLayer = CAShapeLayer()
    private var traitRegistration: UITraitChangeRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
        setTabBarAppearance()
        addTabBarColors()
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged), name: .appThemeChanged, object: nil)
        if #available(iOS 17.0, *) {
            traitRegistration = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: TabBarController, _) in
                self.addTabBarColors()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 17.0, *), let reg = traitRegistration {
            unregisterForTraitChanges(reg)
            traitRegistration = nil
        }
    }
        
      
    
    private func generateTabBar() {
        viewControllers = [
            generateVC(viewController: NotesViewController(), title: "Notes", image: UIImage(systemName: "note.text")),
            generateVC(viewController: FavoritesViewController(), title: "Favorites", image: UIImage(systemName: "star.fill")),
            generateVC(viewController: SettingsViewController(), title: "Settings", image: UIImage(systemName: "gearshape.fill"))
        ]
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
    
    private func setTabBarAppearance() {
        let posX = CGFloat(10)
        let posY = CGFloat(14)
        let width = tabBar.bounds.width - posX * 2
        let height = tabBar.bounds.height + posY * 2
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: posX, y: tabBar.bounds.minY - posY, width: width, height: height), cornerRadius: height / 2)
        roundLayer.path = bezierPath.cgPath
        tabBar.layer.insertSublayer(roundLayer, at: 0)
        tabBar.itemWidth = width / 5
        tabBar.itemPositioning = .centered
//        roundLayer.fillColor = UIColor(named: "tabBarBackground")?.cgColor
//        tabBar.tintColor = UIColor.iconColor
//        tabBar.unselectedItemTintColor = UIColor.unselectedIconColor
    }
    
    private func addTabBarColors() {
        let bg = UIColor(named: "tabBarBackground", in: nil, compatibleWith: traitCollection) ?? .secondarySystemBackground
        roundLayer.fillColor = bg.cgColor
        tabBar.tintColor = UIColor(named: "iconColor", in: nil, compatibleWith: traitCollection)
        tabBar.unselectedItemTintColor = UIColor(named: "unselectedIconColor", in: nil, compatibleWith: traitCollection)
    }
    
    @objc private func onThemeChanged() {
        addTabBarColors()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 17.0, *) {
            
        } else if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            addTabBarColors()
        }
    }
}
