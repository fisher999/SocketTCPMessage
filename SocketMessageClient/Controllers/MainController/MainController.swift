//
//  MainController.swift
//  SocketMessageClient
//
//  Created by Victor on 30.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    //MARK: Tasks
    enum Task: String, CaseIterable {
        case task1 = "Chat with my server"
        case task2 = "Scan network"
        case task3 = "Free communication"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib: UINib = UINib(nibName: TaskCell.id, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: TaskCell.id)
        
        self.tableView.separatorStyle = .none
    }
}

//MARK: -Routing controllers
private extension MainController {
    //MARK: ChatController
    func pushChatController() {
        showChatControllerAlert {[weak self] text in
            guard let text = text, let port = Int(text) else {
                self?.pushChatController()
                return
            }
            let chatController = ChatController(port: port)
            self?.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    func showChatControllerAlert(textHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: "Please, select port", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.keyboardType = .numberPad
        let action = UIAlertAction(title: "Ok", style: .default) { (_) in
            let text = alert.textFields?.first?.text
            textHandler(text)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: ScanNetworkController
    func pushScanController() {
        let scanController = ScanController()
        self.navigationController?.pushViewController(scanController, animated: true)
    }
}

//MARK: -UITableViewDelegate
extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = Task.allCases[indexPath.row]
        switch task {
        case .task1:
            pushChatController()
        case .task2:
            pushScanController()
            break
        case .task3:
            //TODO
            break
        }
    }
}

//MARK: -UITableViewDataSource
extension MainController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.id, for: indexPath) as! TaskCell
        cell.model = Task.allCases[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Task.allCases.count
    }
}
