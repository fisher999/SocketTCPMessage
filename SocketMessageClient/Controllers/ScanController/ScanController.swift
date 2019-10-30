//
//  ScanController.swift
//  SocketMessageClient
//
//  Created by Victor on 30.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import MMLanScan

class ScanController: UIViewController {
    enum State {
        case `default`
        case scanning
        case didScanned
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var progressView: UIProgressView!
    @IBOutlet fileprivate weak var sendMessagesButton: UIButton!
    
    //MARK: Service
    private let lanScanner: MMLANScanner = MMLANScanner()
    
    //MARK: Model
    private var devices: [MMDevice] = []
    private var state: State = .default
        
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    
    //MARK: Setup
    private func setup() {
        let nib: UINib = UINib(nibName: DeviceCell.id, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: DeviceCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        
        lanScanner.delegate = self
        showProgress(false)
        setupRefresh()
    }
}

//MARK: -UITableViewDelegate
extension ScanController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //MARK: Todo
    }
}

//MARK: -UITableViewDataSource
extension ScanController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceCell.id) as! DeviceCell
        let device = self.devices[indexPath.row]
        cell.model = DeviceCell.Model(ip: device.ipAddress, port: device.hostname, computerName: device.brand)
        return cell
    }
}

//MARK: -View
private extension ScanController {
    func setupRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: -Actions
private extension ScanController {
    @objc func didRefresh() {
        switch state {
        case .default, .didScanned:
            reload()
        default:
            return
        }
    }
}

//MARK: -Scanner
extension ScanController: MMLANScannerDelegate {
    //MARK: MMLanScannerDelegate
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        self.addNewDevice(device)
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        switch status {
        case MMLanScannerStatusFinished:
            finish(withMessage: "Scan did finished!")
        case MMLanScannerStatusCancelled:
            finish(withMessage: "Scanner was canceled!")
        default:
            return
        }
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        self.progressView.progress = pingedHosts
    }
    
    func lanScanDidFailedToScan() {
        finish(withMessage: "Failed to scan :(")
    }
    
    //MARK: Scanning
    private func startScan() {
        self.lanScanner.start()
        self.state = .scanning
    }
    
    private func stopScan() {
        self.lanScanner.stop()
        self.state = .default
    }
    
    //MARK: Helping methods
    private func reload() {
        self.devices = []
        self.tableView.reloadData()
    }
    
    private func finish(withMessage message: String) {
        showAlert(message: message)
        showProgress(false)
        self.state = .didScanned
    }
    
    private func showProgress(_ show: Bool) {
        self.progressView.isHidden = !show
    }
    
    private func addNewDevice(_ device: MMDevice) {
        devices.append(device)
        let indexPath = IndexPath(row: devices.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.endUpdates()
    }
}
