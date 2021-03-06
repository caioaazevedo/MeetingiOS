//
//  ContactViewController.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

/// View Controller para selecionar os contatos para reunião
@objc class ContactViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var contactTableView : UITableView!
    @IBOutlet weak var selectedContactsConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties
    private var contactTableViewManager : ContactTableView!
    @objc weak var contactCollectionView : ContactCollectionView?
    
    //MARK:- Computed Properties
    private var isSearchNameEmpty : Bool {
        self.navigationItem.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering : Bool {
        return !isSearchNameEmpty
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactTableViewManager = ContactTableView(self)
        self.setupTableViewContacts()
        self.setupNavigationController()
        
        contactCollectionView?.isRemoveContact = true
        collectionView.delegate = contactCollectionView
        collectionView.dataSource = contactCollectionView
    
        self.collectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionCell")
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.deselectContactInRow), name: NSNotification.Name(rawValue: "RemoveContact"), object: nil)
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
            
            case .authorized, .notDetermined:
                
                self.contactTableViewManager.fetchingContacts { (acess) in
                    if acess {
                        DispatchQueue.main.async {
                            self.contactTableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
            }
            
            
            case .restricted, .denied:
                
                let alert = UIAlertController(title: nil, message: NSLocalizedString("This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", comment: ""), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .default) { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                present(alert, animated: true)
            
            default:
                break
        }
        
        self.markAllSelectedContacts()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if self.contactCollectionView?.contacts.count ?? 0 > 0 {
            self.animateCollection(.show)
        }
    }
    
   
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    /// Setup inicial da table view dos contatos.
    func setupTableViewContacts() {        
        self.contactTableView.delegate = contactTableViewManager
        self.contactTableView.dataSource = contactTableViewManager
        self.contactTableView.allowsSelectionDuringEditing = true
        self.contactTableView.allowsMultipleSelection = true
        self.contactTableView.allowsMultipleSelectionDuringEditing = true
        self.contactTableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        self.contactTableView.register(UINib(nibName: "NewContactTableViewCell", bundle: nil), forCellReuseIdentifier: "NewContactCell")
    }
    
    /// Confirmando contatos selecionados para a reunião.
    @objc func sendingContactsToMeeting() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Marcando todos os contatos que foram selecionados anteriormente.
    func markAllSelectedContacts() {
        
        if let contacts = contactCollectionView?.contacts {
            for contact in contacts {
                
                if let firstChar = contact.name?.first {
                    
                    let key = firstChar.isNumber ? "#" : firstChar.uppercased()
                    
                    let selectedContact = self.contactTableViewManager.contacts[key]?.first(where: { 
                        return $0.email == contact.email
                    })
                    
                    selectedContact?.isSelected = true
                }
            }
        }
    }
    
}

//MARK:- UINavigationController
extension ContactViewController {
    
    /// Configurando navigation controller
    func setupNavigationController() {
                
        self.navigationItem.title = NSLocalizedString("Add participants", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendingContactsToMeeting))
                
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Contacts", comment: "")
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        definesPresentationContext = true
    }
    
}

//MARK:- UICollectionView
extension ContactViewController {
    
    enum Animation {
        case show
        case hide
    }
    
    /// Animando a collection view. 
    /// - Parameter animation: mostrar ou esconder a collection view.
    func animateCollection(_ animation : Animation) {
        
        UIView.animate(withDuration: 0.5) { 
            switch animation {
                case .hide:
                    self.selectedContactsConstraint.constant = 0
                case .show:
                    self.selectedContactsConstraint.constant = self.view.frame.height * 0.15
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    /// Deselecionar um contanto que foi removido pela collection view.
    @objc func deselectContactInRow(_ notification : NSNotification) {
                        
        guard let contact = notification.object as? Contact,  let firstChar = contact.name?.first else {return}
        
        let key = firstChar.isNumber ? "#" : firstChar.uppercased()

        let deselectedContact = self.contactTableViewManager.contacts[key]?.first(where: { 
            return $0.email == contact.email
        })
        
        deselectedContact?.isSelected = false
        
        for indexPath in contactTableView.indexPathsForSelectedRows ?? [] {
            if let cell = contactTableView.cellForRow(at: indexPath) as? ContactTableViewCell {
                if cell.contact == deselectedContact {
                    self.contactTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.hide)
        }
        
    }
}

//MARK:- UISearchResultsUpdating
extension ContactViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = self.navigationItem.searchController?.searchBar.text?.lowercased() else {return}
        var filteringContacts : [Contact] = []
        
        self.contactTableViewManager.sortedContacts.forEach {
            $1.forEach { (contact) in
                if contact.name?.lowercased().contains(text) ?? false || contact.email?.lowercased().contains(text) ?? false {
                    filteringContacts.append(contact)
                }
            }
        }
        
        self.contactTableViewManager.filteredContacts = filteringContacts
        self.contactTableView.reloadData()  
    }
    
}

//MARK:- ContactTableViewDelegate 
extension ContactViewController : ContactTableViewDelegate {
    
    /// Adicionando contatos a collection view que foram selecionados.
    /// - Parameter contact: contato selecionado.
    func addContact(contact: Contact) {
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.show)
        }        
        
        self.contactCollectionView?.addContact(contact)
            
        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
        
        self.collectionView.insertItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    
    }
    
    /// Removendo contatos da collection view que foram deselecionados.
    /// - Parameter contact: contato deselecionado.
    func removeContact(contact: Contact) {
        
        let index = self.contactCollectionView?.contacts.firstIndex(where: {
            return $0.email == contact.email
        })
        
        let indexPath = IndexPath(item: index!, section: 0)
        
          self.collectionView.scrollToItem(at: IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0), at: .left, animated: true)
        self.contactCollectionView?.removeContactIndex(indexPath.item)
        self.collectionView.deleteItems(at: [indexPath])  
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.hide)
        }
    }
}

//MARK:- Add New Contact 
extension ContactViewController  {
    
    /// Adicionando um novo contato por dentro do nosso app.
    /// - Parameter sender: bar button clicado.
    @IBAction func addingNewContact(_ sender : Any) {
        
        let newContact = CNContactViewController(forNewContact: nil)
        newContact.contactStore = CNContactStore()
        newContact.allowsActions = false
        newContact.delegate = self
        newContact.view.layoutIfNeeded()
        
        let navigationController = UINavigationController(rootViewController: newContact)
        navigationController.view.layoutIfNeeded()
        
        self.present(navigationController, animated: true, completion: nil)
    }
}


//MARK:- CNContactViewControllerDelegate
extension ContactViewController : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
                        
        if contact == nil  {
            viewController.dismiss(animated: true, completion: nil)
        } else {
            
            if let email = contact?.emailAddresses.first?.value as String?, !email.isEmpty, contact?.givenName.count ?? 0 > 0 {
                
                let contact = Contact(contact: contact!)
                self.addContact(contact: contact)
                
                viewController.dismiss(animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: NSLocalizedString("Error to add contact", comment: ""), message: NSLocalizedString("Name or email empty", comment: ""), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    viewController.dismiss(animated: true, completion: nil)
                }))
                
                viewController.present(alert, animated: true, completion: nil)            
            }
        }
    }
    
}



