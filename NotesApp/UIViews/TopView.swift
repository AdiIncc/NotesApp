import UIKit

class TopView: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let actionButton: UIButton?
    
    // MARK: - Initialization
    
    init(actionbutton: UIButton?) {
        self.actionButton = actionbutton
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI SETUP
    
    private func setupLayout() {
        self.backgroundColor = .secondarySystemBackground
        self.addSubview(titleLabel)
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5))
        
        if let button = actionButton {
            self.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            constraints.append(button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16))
            constraints.append(button.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor))
            constraints.append(titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -8))
            constraints.append(button.widthAnchor.constraint(equalToConstant: 40))
            constraints.append(button.heightAnchor.constraint(equalToConstant: 40))
        }
        NSLayoutConstraint.activate(constraints)
    }
}
