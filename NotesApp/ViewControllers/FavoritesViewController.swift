//
//  FavoritesViewController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    let tableView = UITableView()
    var topView: TopView!
    var favoriteNotes: [Notes] = []
    var allNotes: [Notes] = [] {
        didSet {
            filterFavoriteNotes()
        }
    }
    private weak var delegate: NotesTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topView = addTopView(title: "Favorites")
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(editNoteFromFavorites(_:)), name: NSNotification.Name("editNote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editNoteFromFavorites(_:)), name: NSNotification.Name("createNote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveInitialNotes(_:)), name: .initialNotesLoad, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .initialNotesLoadRequest, object: nil)
    }
    
    @objc func receiveInitialNotes(_ notification: Notification) {
        if let initialNotes = notification.userInfo?["allNotes"] as? [Notes] {
            self.allNotes = initialNotes
        }
    }
    
    func filterFavoriteNotes() {
        favoriteNotes = allNotes.filter { $0.isFavourite }
        tableView.reloadData()
    }
    
    @objc func editNoteFromFavorites(_ notification: Notification) {
        var wasModified = false
        if let newNote = notification.userInfo?["newNote"] as? Notes {
            allNotes.append(newNote)
            wasModified = true
        }
        if let updateNote = notification.userInfo?["updateNote"] as? Notes {
            if let index = allNotes.firstIndex(where: { $0.id == updateNote.id }) {
                allNotes[index] = updateNote
            } else {
                allNotes.append(updateNote)
            }
            wasModified = true
        }
        if wasModified {
            filterFavoriteNotes()
        }
    }
    

}
//MARK: - TableView setup
extension FavoritesViewController {
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NotesTableViewCell.self, forCellReuseIdentifier: NotesTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

//MARK: - TableView Delegate and DataSource
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier, for: indexPath) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        let note = favoriteNotes[indexPath.row]
        cell.configure(with: note, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = favoriteNotes[indexPath.row]
        self.editNote(id: selectedNote.id)
    }
}

//MARK: - Conforms to NotesTableViewCellDelegate
extension FavoritesViewController: NotesTableViewCellDelegate {
    func addFavorites(id: String, added: Bool) {
        if let index = allNotes.firstIndex(where: { $0.id == id }) {
            allNotes[index].isFavourite = added
            filterFavoriteNotes()
            let updatedNote = allNotes[index]
            NotificationCenter.default.post(name: NSNotification.Name("editNote"), object: self, userInfo: ["updateNote" : updatedNote])
        }
    }
    func editNote(id: String) {
        let note = allNotes.first { note in
            note.id == id
        }
        guard let note = note else { return }
        let editTaskVC = AddNotesViewController(notes: note)
        present(editTaskVC, animated: true)
    }
}
