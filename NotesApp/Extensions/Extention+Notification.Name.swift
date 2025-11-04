//
//  Extention+Notification.Name.swift
//  NotesApp
//
//  Created by Adrian Inculet on 31.10.2025.
//

import Foundation

extension Notification.Name {
    static let favoritesUpdates = Notification.Name("favoritesUpdates") 
    static let initialNotesLoad = Notification.Name("initialNotesLoad")
    static let initialNotesLoadRequest = Notification.Name("initialNotesLoadRequest")
}
