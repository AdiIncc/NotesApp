//
//  AddNotesViewController.swift
//  NotesApp
//
//  Created by Adrian Inculet on 30.10.2025.
//

import UIKit
import Lottie

class AddNotesViewController: UIViewController {

    var topView: TopView!
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()
    
    lazy var textView : UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.text = "Add note..."
        textView.layer.cornerRadius = 8
        textView.autocorrectionType = .no
        return textView
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 15, weight: .bold)
        textField.placeholder = "Title"
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 8
        textField.textColor = UIColor.label
        textField.autocorrectionType = .no
        return textField
    }()
    
    lazy var lottieView = LottieAnimationView()
    private var notes: NoteEntity?
    
    private var lottieViewBottomConstraint: NSLayoutConstraint?
    
    var caption: String {
        get { return textView.text}
        set { textView.text = newValue }
    }
    
    var noteTitle: String {
        get { return textField.text ?? "" }
        set { textField.text = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topView = addTopView(title: "Add note", actionImageName: "checkmark.circle.fill", actionTarget: self, actionSelector: #selector(saveNoteButtonTapped))
        textView.delegate = self
        setupViews()
        setupConstraints()
        setupLottieAnimation()
        tapGestureRecognizer()
        initNotes()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboard.height
        self.lottieViewBottomConstraint?.constant = -keyboardHeight
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        if textView.isFirstResponder {
            lottieView.play()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        self.lottieViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        if !textView.text.isEmpty && textView.textColor != .placeholderText {
            lottieView.pause()
        }
    }
    
    init(notes: NoteEntity? = nil) {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        self.notes = notes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initNotes() {
        if let notes = notes {
            textView.text = notes.caption
            textField.text = notes.title
            textField.textColor = .label
        } else {
            textView.text = "Add a note..."
            textView.textColor = .placeholderText
        }
    }
    
    @objc func dismissView() {
        closeView()
    }
    
    @objc func saveNoteButtonTapped() {
        guard let notesCaption = textView.text,
              let noteTitle = textField.text, notesCaption.count >= 4, noteTitle.count >= 4 else {
            presentError(title: "Save error", message: "The note and the title should be at least 4 characters long.")
            return
        }
        if let notes = notes {
            notes.title = noteTitle
            notes.caption = notesCaption
            CoreDataManager.shared.saveContext()
            let updatedNote = Notes(id: notes.id ?? UUID().uuidString, title: noteTitle, caption: notesCaption, createdAt: notes.createdAt ?? Date(), isFavourite: notes.isFavourite, isTrashed: notes.isTrashed)
            let userInfo: [String : Notes] = ["updateNote" : updatedNote]
            NotificationCenter.default.post(name: NSNotification.Name("editNote"), object: nil, userInfo: userInfo)
        } else {
            CoreDataManager.shared.createNewNote(title: noteTitle, caption: notesCaption)
            let notesId = UUID().uuidString
            let notes = Notes(id: notesId, title: noteTitle, caption: notesCaption, createdAt: Date(), isFavourite: false, isTrashed: false)
            let userInfo: [String : Notes] = ["newNote" : notes]
            NotificationCenter.default.post(name: NSNotification.Name("createNote"), object: nil, userInfo: userInfo)
        }
        closeView()
    }
    
    private func closeView() {
        dismiss(animated: true)
    }
    //MARK: - Setup Views
    private func setupViews() {
        topView.addSubview(backButton)
        view.addSubview(textField)
        view.addSubview(textView)
        view.addSubview(lottieView)
    }
    //MARK: - Setup UI
    private func setupConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(backButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16))
        constraints.append(backButton.centerYAnchor.constraint(equalTo: topView.titleLabel.centerYAnchor))
        constraints.append(backButton.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(backButton.heightAnchor.constraint(equalToConstant: 40))
        
        constraints.append(textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15))
        constraints.append(textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15))
        constraints.append(textField.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20))
        constraints.append(textField.heightAnchor.constraint(equalToConstant: 50))
        
        constraints.append(textView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20))
        constraints.append(textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15))
        constraints.append(textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15))
        constraints.append(textView.bottomAnchor.constraint(equalTo: lottieView.topAnchor, constant: 0))
        
        let initialBottomConstraint = lottieView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.lottieViewBottomConstraint = initialBottomConstraint
        
//        constraints.append(lottieView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0))
        constraints.append(lottieView.centerXAnchor.constraint(equalTo: textView.centerXAnchor))
        constraints.append(lottieView.heightAnchor.constraint(equalToConstant: 250))
        constraints.append(lottieView.widthAnchor.constraint(equalToConstant: 250))
        constraints.append(initialBottomConstraint)
        
        NSLayoutConstraint.activate(constraints)
    }
    //MARK: - Setup Lottie Animation
    private func setupLottieAnimation() {
        let animation = LottieAnimation.named("working_boy")
        lottieView.animation = animation
        if lottieView.animation == nil {
            print("Error loading the animation")
            return
        }
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
    }

}
//MARK: - Dismiss keyboard when tapping anywhere besides textView or textField
extension AddNotesViewController: UIGestureRecognizerDelegate {
    func tapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
//MARK: - TextView Delegate
extension AddNotesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
        lottieView.play()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note..."
            textView.textColor = .placeholderText
            lottieView.pause()
        } else {
            lottieView.pause()
        }
    }
}
