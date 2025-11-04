//
//  SettingsViewController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    lazy var settingLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your app theme!"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var settingsView: UIView = {
        let width = view.frame.width - CGFloat(30)
        let height = CGFloat(200)
        let frame = CGRect(x: 15, y: view.center.y - (height / 2), width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    lazy var segmentedController: UISegmentedControl = {
        let segment = UISegmentedControl()
        for (index, theme) in AppTheme.allCases.enumerated() {
            let image = UIImage(systemName: theme.systemIcon)
            segment.insertSegment(with: image, at: index, animated: false)
        }
        segment.selectedSegmentIndex = ThemeManager.shared.current.rawValue
        segment.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        return segment
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addTopView(title: "Settings")
        view.addSubview(settingsView)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged(_:)), name: .appThemeChanged, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingsView.layer.cornerRadius = 8
    }
    
    @objc private func themeChanged(_ sender: UISegmentedControl) {
        guard let theme = AppTheme(rawValue: sender.selectedSegmentIndex) else { return }
        ThemeManager.shared.current = theme
    }
    
    @objc private func onThemeChanged(_ note: Notification) {
        segmentedController.selectedSegmentIndex = ThemeManager.shared.current.rawValue
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        settingLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedController.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(settingLabel)
        settingsView.addSubview(segmentedController)
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(settingLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: 30))
        constraints.append(settingLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 15))
        constraints.append(settingLabel.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -15))
        constraints.append(segmentedController.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 15))
        constraints.append(segmentedController.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -15))
        constraints.append(segmentedController.centerYAnchor.constraint(equalTo: settingsView.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }
    
}

