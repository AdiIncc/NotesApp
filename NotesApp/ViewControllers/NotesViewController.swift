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
    var fetchedResultController: NSFetchedResultsController<NoteEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topView = addTopView(title: "Notes", actionImageName: "plus", actionTarget: self, actionSelector: #selector(addButtonDidTap))
        setupTableView()
        setupFetchedResultController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultController.performFetch()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func addButtonDidTap() {
        let addNoteVC = AddNotesViewController()
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .overFullScreen
        present(addNoteVC, animated: true)
    }
    
    func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "isTrashed == NO")
        fetchRequest.predicate = predicate
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
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
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier, for: indexPath) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        let noteEntity = fetchedResultController.object(at: indexPath)
        cell.configure(with: noteEntity, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToTrash = fetchedResultController.object(at: indexPath)
            
            CoreDataManager.shared.trashNote(note: noteToTrash, shouldTrash: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = fetchedResultController.object(at: indexPath)
        guard let noteId = selectedNote.id else { return }
        self.editNote(id: noteId)
    }
}

//MARK: - NotesViewController conform to NotesTableViewCellDelegate
extension NotesViewController: NotesTableViewCellDelegate {
    func addFavorites(id: String, added: Bool) {
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let result = try CoreDataManager.shared.context.fetch(fetchRequest)
            if let noteToUpdate = result.first {
                noteToUpdate.isFavourite = added
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editNote(id: String) {
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let result = try CoreDataManager.shared.context.fetch(fetchRequest)
            if let noteEntityToUpdate = result.first {
                let editTaskVC = AddNotesViewController(notes: noteEntityToUpdate)
                present(editTaskVC, animated: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension NotesViewController:  NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default :
            tableView.reloadData()
        }
    }
}
