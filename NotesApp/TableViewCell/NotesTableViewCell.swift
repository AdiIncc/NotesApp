//
//  NotesTableViewCell.swift
//  NotesApp
//
//  Created by Adrian Inculet on 30.10.2025.
//

import UIKit

protocol NotesTableViewCellDelegate: AnyObject {
    func addFavorites(id: String, added: Bool)
    func editNote(id: String)
}

class NotesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "NotesTableViewCell"
    
    lazy var cellView = UIView()
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Here will be the content"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var favoritesImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        imageView.image = UIImage(systemName: "star", withConfiguration: config)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .iconColor
        return imageView
    }()
    
    lazy var dataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "2025-10-30"
        return label
    }()
    var delegate: NotesTableViewCellDelegate?
    private var notes: Notes!
    
    private var dataFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupCellViews()
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Selection style applied on the cellView
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let targetAlpha: CGFloat = highlighted ? 0.8 : 1
        if animated {
            UIView.animate(withDuration: 1.0,) {
                self.cellView.alpha = targetAlpha
            }
        } else {
            self.cellView.alpha = targetAlpha
        }
    }
    
//MARK: - Cell UI setup
    private func setupCell() {
        cellView.backgroundColor = .secondarySystemBackground
        cellView.layer.cornerRadius = 8
        cellView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesImageView.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var contraints = [NSLayoutConstraint]()
        
        contraints.append(cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10))
        contraints.append(cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        contraints.append(cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        contraints.append(cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        
        contraints.append(titleLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10))
        contraints.append(titleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 15))
        contraints.append(titleLabel.trailingAnchor.constraint(equalTo: favoritesImageView.leadingAnchor, constant: -10))
        
        contraints.append(contentLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 15))
        contraints.append(contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5))
        contraints.append(contentLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -20))
        
        contraints.append(favoritesImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10))
        contraints.append(favoritesImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor))
        contraints.append(favoritesImageView.heightAnchor.constraint(equalToConstant: 30))
        contraints.append(favoritesImageView.widthAnchor.constraint(equalToConstant: 30))
        
        contraints.append(dataLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10))
        contraints.append(dataLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 15))
        contraints.append(dataLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -10))
        
        NSLayoutConstraint.activate(contraints)
    }
//MARK: - Views setup
    private func setupCellViews() {
        contentView.addSubview(cellView)
        cellView.addSubview(titleLabel)
        cellView.addSubview(contentLabel)
        cellView.addSubview(favoritesImageView)
        cellView.addSubview(dataLabel)
    }
//MARK: - Cell configure
    func configure(with note: Notes, delegate: NotesTableViewCellDelegate?) {
        titleLabel.text = note.title
        contentLabel.text = note.caption
        favoritesImageView.image = note.isFavourite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        dataLabel.text = dataFormatter.string(from: note.createdAt)
        let tap = UITapGestureRecognizer(target: self, action: #selector(addedToFavorites))
        favoritesImageView.addGestureRecognizer(tap)
        favoritesImageView.isUserInteractionEnabled = true
        self.notes = note
        self.delegate = delegate
    }
    
    @objc func addedToFavorites() {
        notes.isFavourite.toggle()
        delegate?.addFavorites(id: notes.id, added: notes.isFavourite)
        favoritesImageView.image = notes.isFavourite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
    
}
