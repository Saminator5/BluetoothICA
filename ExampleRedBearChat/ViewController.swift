//
//  ViewController.swift
//  ExampleRedBearChat
//
//  Created by Eric Larson on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit

// MARK: CHANGE 2a: No longer should to be a delegate
class ViewController: UIViewController, BLEDelegate {
    
    // MARK: VC Properties
    // MARK: CHANGE 2.b and 3: Add support for lazy instantiation (like we did in the table view controller)
    var bleShield = BLE()
    var rssiTimer = Timer()
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var buttonConnect: UIButton!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var rssiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: CHANGE 1.a: change this as you no longer need to instantiate the BLE Object like this
        //   you should not let this ViewController be the BLE delegate
        bleShield.delegate = self
        
        // MARK: CHANGE 4: add subscription to notifications from the app delegate
        // These selector functions should be created from the old BLEDelegate functions
        // One example has already been completed for you on the receiving of data function
        
        // BLE Connect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidConnectNotification),
                                               name: NSNotification.Name(rawValue: kBleConnectNotification),
                                               object: nil)
        
        // BLE Disconnect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidDisconnectNotification),
                                               name: NSNotification.Name(rawValue: kBleDisconnectNotification),
                                               object: nil)
        
        // BLE Disconnect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidRecieveDataNotification),
                                               name: NSNotification.Name(rawValue: kBleReceivedDataNotification),
                                               object: nil)
        
        
    }
    
    func readRSSITimer(timer:Timer){
        bleShield.readRSSI { (number, error) in
            // when RSSI read is complete, display it
            self.rssiLabel.text = String(format: "%.1f",(number?.floatValue)!)
        }
    }

    // MARK: Delegate Methods
    func bleDidUpdateState() {
        
    }
    // MARK :CHANGE 7: create function called from "BLEDidConnect" notification (you can change the function below)
    // in this function, update a label on the UI to have the name of the active peripheral
    // you might be interested in the following method (from objective C):
    // NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    // now just wait to send or receive
    // NEW  CONNECT FUNCTION
    @objc func onBLEDidConnectNotification(notification:Notification){
        print("Notification that BLE Connected ")
    }
    
    // OLD DELEGATION CONNECT FUNCTION
    func bleDidConnectToPeripheral() {
        self.spinner.stopAnimating()
        self.buttonConnect.setTitle("Disconnect", for: .normal)
        
        // Schedule to read RSSI every 1 sec.
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                         repeats: true,
                                         block: self.readRSSITimer)

    }
    
    // OLD DELEGATION DISCONNECT FUNCTION
    func bleDidDisconnectFromPeripheral() {
        // MARK: CHANGE 5.b: remove all accesses of the "connect button"
        self.buttonConnect.setTitle("Connect", for: .normal)
        rssiTimer.invalidate()
    }
    
    // NEW  DISCONNECT FUNCTION
    @objc func onBLEDidDisconnectNotification(notification:Notification){
        print("Notification that BLE Disconneected Peripheral")
    }
    
    // OLD FUNCTION: parse the received data using BLEDelegate protocol
    func bleDidReceiveData(data: Data?) {
        // this data could be anything, here we know its an encoded string
        let s = String(bytes: data!, encoding: String.Encoding.utf8)
        labelText.text = s

    }
    
    // NEW FUNCTION EXAMPLE: this was written for you to show how to change to a notification based model
    @objc func onBLEDidRecieveDataNotification(notification:Notification){
        let d = notification.userInfo?["data"] as! Data?
        let s = String(bytes: d!, encoding: String.Encoding.utf8)
        self.labelText.text = s
    }
    
    // MARK: User initiated Functions
    // MARK: CHANGE 1.b: change this as you no longer need to search for perpipherals in this view controller
    @IBAction func buttonScanForDevices(_ sender: UIButton) {
        
        // disconnect from any peripherals
        var didDisconnect = false
        for peripheral in bleShield.peripherals {
            if(peripheral.state == .connected){
                if(bleShield.disconnectFromPeripheral(peripheral: peripheral)){
                    didDisconnect = true
                }
            }
        }
        // if we disconnected anything, return from button
        if(didDisconnect){
            return
        }
        
        //start search for peripherals with a timeout of 3 seconds
        // this is an asynchronous call and will return before search is complete
        if(bleShield.startScanning(timeout: 3.0)){
            // after three seconds, try to connect to first peripheral
            Timer.scheduledTimer(withTimeInterval: 3.0,
                                 repeats: false,
                                 block: self.connectTimer)
        }
        
        // give connection feedback to the user
        self.spinner.startAnimating()
    }
    
    // MARK: CHANGE 1.c: change this as you no longer need to create the connection in this view controller
    // Called when scan period is over to connect to the first found peripheral
    func connectTimer(timer:Timer){
        
        if(bleShield.peripherals.count > 0) {
            // connect to the first found peripheral
            bleShield.connectToPeripheral(peripheral: bleShield.peripherals[0])
        }
        else {
            self.spinner.stopAnimating()
        }
    }
    
    // MARK: CHANGE: this function only needs a name change, the BLE writing does not change
    @IBAction func sendDataButton(_ sender: UIButton) {
        
        let s = textBox.text!
        let d = s.data(using: String.Encoding.utf8)!
        bleShield.write(d)
        // if (self.textField.text.length > 16)
    }
    
}








