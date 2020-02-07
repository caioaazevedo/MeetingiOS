//
//  ConclusionsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionsViewController: UITableViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var viewTopic: UIView!
    @IBOutlet weak var viewAuthor: UIView!
    
    //Conclusion
    @IBOutlet weak var conclusionTableView: UITableView!
    private var conclusionManager : ConclusionInfoTableViewManager!
    @IBOutlet private weak var contentViewConclusionTableView : UIView!
    
    @IBOutlet var labelAuthorName: UILabel!
    @IBOutlet weak var labelTopicTitle: UILabel!
    @IBOutlet weak var labelTimeDiscussed: UILabel!
    
    //Description
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    private var descriptionManager : DescriptionTableViewManager!
    
    /// Conclusions vindos do Tópico Seelecionado
    var topicToPresentConclusions: Topic!
    
    /// Flag para saber se viemos da UnfinishedMeetingViewController
    var fromUnfinishedMeeting = false
    
    var meetingDidBegin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.conclusionManager = ConclusionInfoTableViewManager()
        self.descriptionManager = DescriptionTableViewManager()

        self.labelAuthorName.text = topicToPresentConclusions.authorName
        
        if let duration = topicToPresentConclusions.duration {
            self.labelTimeDiscussed.text = String(describing: duration)
        } else {
            self.labelTimeDiscussed.text = "00:00"
        }
        
        self.labelTopicTitle.text = topicToPresentConclusions.topicDescription
        self.labelAuthorName.text = topicToPresentConclusions.authorName

        self.descriptionTextView.delegate = descriptionManager
        
        self.setupConclusionsAndDescription()
        
        //Setup da Conclusion
        conclusionManager.viewControler = self
        conclusionTableView.delegate = self.conclusionManager
        conclusionTableView.dataSource = self.conclusionManager
        conclusionManager.conclusionTableView = conclusionTableView
        
        /// Configuração da Navigation - Título e ação do botão Done
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        navigationItem.title = "Details"
        
        // Arredondando bordas da View
        self.viewTopic.setupCornerRadiusShadow()
        self.viewAuthor.setupCornerRadiusShadow()
        self.contentViewConclusionTableView.setupCornerRadiusShadow()
        self.descriptionView.setupCornerRadiusShadow()
        
        /// Reconhece o gesto e o adiciona na tela
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        /// Dispara as funções de manipulação do teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.topicToPresentConclusions.conclusions.append("")
    }
    
    
    
    /// Ação do botão Done para mandar a conclusiona para o Cloud
    @objc func doneAction() {        
        
        let loading = UIAlertController(title: nil, message: "Topic update...", preferredStyle: .alert)
        loading.addUIActivityIndicatorView()
        
        self.present(loading, animated: true, completion: nil)
        
        //Removendo último em branco
        self.topicToPresentConclusions.conclusions.removeLast()
        
        CloudManager.shared.updateRecords(records: [topicToPresentConclusions.record], perRecordCompletion: { (record, error) in
            if let error = error {
                print("Error Cloud: \(error)")
            } else {
                print("Conclusion Successifuly added!")
                
                DispatchQueue.main.async {
                    loading.dismiss(animated: true, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }) {
            print("Done Request")
        }
    
    }
    
    /// Remove o teclado da tela
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Eleva a tela para o teclado aparecer
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    /// Volta a tela para o normal sem o teclado
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}


//MARK:- TableViewConfig
extension ConclusionsViewController {
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let title = UILabel()
        
        switch section {
            case 0,1:
                view.backgroundColor = .clear
            case 2,3:
                title.font = UIFont(name: "SFProText-Bold", size: 17)    
                title.textColor = UIColor(named: "ColorConclusionDescriptionHeader")
                title.text = section == 2 ? "Description" : "Conclusion"
                view.backgroundColor = UIColor(named: "ColorTableViewCell")
                view.addSubview(title)
                title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
                title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                title.translatesAutoresizingMaskIntoConstraints = false
                view.setupShadow()
            default:
                break
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        
        switch indexPath.section {
            case 0:
                height = self.view.frame.height * 0.1
            case 1:
                height = self.view.frame.height * 0.1 + 30 // 30 da constraint de bottom
            case 2:
                height = self.view.frame.height * 0.2
            case 3:
                height = self.view.frame.height * 0.3
            default:
                break
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var height = CGFloat()
        
        switch section {
            case 0:
                height = 20
            case 1:
                height = 40
            default:
                height = 45
        }
        
        return height
    }
}

//MARK:- Setup Description/Conclusions
extension ConclusionsViewController {
    
    func setupConclusionsAndDescription() {
        
        /// Section 2 -> Descrição    |      Section 3 -> Conslusões        
        descriptionTextView.isUserInteractionEnabled = fromUnfinishedMeeting && (topicToPresentConclusions.author?.recordID.recordName == UserDefaults.standard.value(forKey: "recordName") as? String)
        
        if self.topicToPresentConclusions.topicDescription.isEmpty {
            self.descriptionTextView.text = "Não especificado"
        } else {
            self.descriptionTextView.text = topicToPresentConclusions.topicPorque
        }

        if !self.meetingDidBegin {
            conclusionManager.fromUnfinishedMeeting = true
            conclusionManager.meetingDidBegin = self.meetingDidBegin
        }
    }
}
