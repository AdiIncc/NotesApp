//
//  CoreDataManager.swift
//  NotesApp
//
//  Created by Adrian Inculet on 04.11.2025.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private let modelName = "NotesApp"
    
    lazy var persistenContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("\(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistenContainer.viewContext
    }
    
    func saveContext() {
        let context = persistenContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let error = error as NSError
                print(("\(error), \(error.userInfo)"))
            }
        }
    }
    
    func createNewNote(title: String, caption: String) {
        let newNote = NoteEntity(context: self.context)
        newNote.id = UUID().uuidString
        newNote.title = title
        newNote.caption = caption
        newNote.createdAt = Date()
        newNote.isFavourite = false
        newNote.isTrashed = false
        
        saveContext()
    }
    
    func toggleNoteFavourite(note: NoteEntity) {
        note.isFavourite.toggle()
        saveContext()
    }
    
    func trashNote(note: NoteEntity, shouldTrash: Bool) {
        note.isTrashed = shouldTrash
        saveContext()
    }
}
