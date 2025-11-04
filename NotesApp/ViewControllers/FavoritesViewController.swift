//
//  FavoritesViewController.swift
//  MyToDoListApp
//
//  Created by Adrian Inculet on 28.10.2025.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    
    let tableView = UITableView()
    var topView: TopView!
    var fetchedResultsController: NSFetchedResultsController<NoteEntity>!
    private weak var delegate: NotesTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topView = addTopView(title: "Favorites")
        setupTableView()
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "isFavourite == YES AND isTrashed == NO")
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Eroare la fetch favorite: \(error.localizedDescription)")
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
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.reuseIdentifier, for: indexPath) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        let note = fetchedResultsController.object(at: indexPath)
        cell.configure(with: note, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToUnfavorite = fetchedResultsController.object(at: indexPath)
            
            noteToUnfavorite.isFavourite = false
            CoreDataManager.shared.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = fetchedResultsController.object(at: indexPath)
        guard let noteId = selectedNote.id else { return }
        self.editNote(id: noteId)
    }
}

//MARK: - Conforms to NotesTableViewCellDelegate
extension FavoritesViewController: NotesTableViewCellDelegate {
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
            print("Eroare la actualizarea favorite din FavoritesVC: \(error.localizedDescription)")
        }
    }
    func editNote(id: String) {
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let result = try CoreDataManager.shared.context.fetch(fetchRequest)
            if let noteEntityToEdit = result.first {
                let editTaskVC = AddNotesViewController(notes: noteEntityToEdit)
                present(editTaskVC, animated: true)
            }
        } catch {
            print("Eroare la fetch pentru editare în FavoritesVC: \(error.localizedDescription)")
        }
    }
}

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
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
            @unknown default:
                tableView.reloadData()
            }
        }
}
