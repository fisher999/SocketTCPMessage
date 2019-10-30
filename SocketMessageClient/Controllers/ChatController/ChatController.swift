//
//  ViewController.swift
//  SocketMessageClient
//
//  Created by Victor on 25.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class ChatController: UIViewController {
    //MARK: View
    @IBOutlet weak fileprivate var textField: UITextField!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //MARK: Services
    private let socketStream: SocketStream
    
    //MARK: Model
    private var text: String?
    private var messages: [MDMessage] = []
        
    //MARK: Init
    init(withHost host: String = "127.0.0.1", port: Int) {
        self.socketStream = SocketStream(withHost: host, port: port)
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.socketStream.connect()
        self.socketStream.delegate = self
        self.textField.delegate = self
        
        self.setupTable()
    }
    
    private func setupTable() {
        let nib: UINib = UINib(nibName: MessageCell.id, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: MessageCell.id)
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: -SocketStreamDelegate
extension ChatController: SocketStreamDelegate {
    func socketStream(_ socketStream: SocketStream, receivedMessage message: String) {
        self.receiveMessage(message)
    }
}

//MARK: -UITableViewDataSource
extension ChatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell: MessageCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self)) as! MessageCell
        messageCell.model = messages[indexPath.row]
        return messageCell
    }
}

//MARK: -Actions
extension ChatController {
    @IBAction private func textFieldValueChanged(_ sender: UITextField) {
        self.text = sender.text
    }
    
    @IBAction private func sendButtonDidTapped(_ sender: UITextField) {
        sendMessage(self.text)
        self.textField.text = nil
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

extension ChatController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: -BussinesLogic
private extension ChatController {
    func sendMessage(_ message: String?) {
        guard let message = message else {return}
        self.socketStream.sendMessage(message)
        self.addNewMessage(message, type: .incoming)
    }
    
    func receiveMessage(_ message: String) {
        addNewMessage(message, type: .outcoming)
    }
    
    func addNewMessage(_ message: String, type: MDMessage.MessageType) {
        let message = MDMessage(message: message, date: Date(), type: type)
        self.messages.append(message)
        insertRows()
    }
    
    func insertRows() {
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

