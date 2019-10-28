//
//  ViewController.swift
//  SocketMessageClient
//
//  Created by Victor on 25.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    //MARK: View
    @IBOutlet weak fileprivate var textField: UITextField!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //MARK: Services
    private let socketStream: SocketStream
    
    //MARK: Model
    private var text: String?
    private var messages: [String] = []
        
    //MARK: Init
    init(withHost host: String, port: Int) {
        self.socketStream = SocketStream(withHost: host, port: port)
        super.init(nibName: nil, bundle: nil)
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
}

//MARK: -SocketStreamDelegate
extension MainController: SocketStreamDelegate {
    func socketStream(_ socketStream: SocketStream, didSendMessage message: String) {
        self.addNewMessage(message)
    }
    
    func socketStream(_ socketStream: SocketStream, receivedMessage message: String) {
        self.receiveMessage(message)
    }
}

//MARK: -UITableViewDataSource
extension MainController: UITableViewDataSource {
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
extension MainController {
    @IBAction private func textFieldValueChanged(_ sender: UITextField) {
        self.text = sender.text
        sender.text = nil
    }
    
    @IBAction private func sendButtonDidTapped(_ sender: UITextField) {
        sendMessage(self.text)
    }
}

extension MainController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: -BussinesLogic
private extension MainController {
    func sendMessage(_ message: String?) {
        guard let message = message else {return}
        self.socketStream.sendMessage(message)
    }
    
    func receiveMessage(_ message: String) {
        addNewMessage(message)
    }
    
    func addNewMessage(_ message: String) {
        self.messages.append(message)
        insertRows()
    }
    
    func insertRows() {
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.endUpdates()
    }
}

