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
    
    //MARK: Services
    private let socketStream: SocketStream
    
    //MARK: Model
    private var text: String?
        
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
    }
}

//MARK: -SocketStreamDelegate
extension MainController: SocketStreamDelegate {
    func socketStream(_ socketStream: SocketStream, receivedMessage message: String) {
        print(message)
    }
}

//MARK: -Actions
extension MainController {
    @IBAction private func textFieldValueChanged(_ sender: UITextField) {
        self.text = sender.text
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
}

