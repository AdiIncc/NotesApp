//
//  ViewController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import UIKit
import CoreData

protocol NotesViewControllerDelegate: AnyObject {
    func editNote(id: String)
}

class NotesViewController: UIViewController {
    
    
    var topView: TopView!
    let tableView = UITableView()
    private weak var delegate: NotesViewControllerDelegate?
    var notes: [Notes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topView = addTopView(title: "Notes", actionImageName: "plus", actionTarget: self, actionSelector: #selector(addButtonDidTap))
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(editNote(_:)), name: NSNotification.Name("editNote"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createNote(_ :)), name: NSNotification.Name("createNote"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(handleInitialNotesLoadRequest),name: .initialNotesLoadRequest,object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .initialNotesLoad, object: nil, userInfo: ["allNotes" : self.notes])
    }
    
    @objc private func handleInitialNotesLoadRequest() {
        NotificationCenter.default.post(name: .initialNotesLoad,object: nil,userInfo: ["allNotes": self.notes])
    }
    
    @objc func addButtonDidTap() {
        let addNoteVC = AddNotesViewController()
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .overFullScreen
        present(addNoteVC, animated: true)
    }
    
    @objc func createNote(_ notification: Notification){
        guard let userInfo = notification.userInfo, let newNote = userInfo["newNote"] as? Notes else { return }
        notes.append(newNote)
        tableView.reloadData()
    }
    
    @objc func editNote(_ notification: Notification){
        guard let userInfo = notification.userInfo, let noteToUpdate = userInfo["updateNote"] as? Notes else { return }
        let noteIndex = notes.firstIndex { note in
            note.id == noteToUpdate.id
        }
        guard let noteIndex = noteIndex else { return }
        notes[noteIndex] = noteToUpdate
        tableView.reloadData()
    }
    
}

// MARK: - Setup TableView

extension NotesViewController {
    
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
//MARK: - NotesViewController conforms to DataSource and Delegate
extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier, for: indexPath) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        let notes = notes[indexPath.row]
        cell.configure(with: notes, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToTrash = notes[indexPath.row]
            
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = notes[indexPath.row]
        self.editNote(id:selectedNote.id)
    }
}

//MARK: - NotesViewController conform to NotesTableViewCellDelegate
extension NotesViewController: NotesTableViewCellDelegate {
    func addFavorites(id: String, added: Bool) {
        let noteIndex = notes.firstIndex { notes in
            notes.id == id
        }
        guard let noteIndex = noteIndex else { return }
        notes[noteIndex].isFavourite = added
        tableView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name("editNote"), object: self, userInfo: ["updateNote" : notes[noteIndex]])
    }
    
    func editNote(id: String) {
        let note = notes.first { note in
            note.id == id
        }
        guard let note = note else { return }
        let editTaskVC = AddNotesViewController(notes: note)
        present(editTaskVC, animated: true)
        
    }
}
