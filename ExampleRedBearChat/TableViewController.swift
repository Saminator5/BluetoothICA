//
//  TableViewController.swift
//  ExampleRedBearChat
//
//  Created by Eric Larson on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    // on access, setup this variable
    lazy var bleShield:BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    var globalPeripheralName = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        self.globalPeripheralName = ""
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(scanForDevices), for: .valueChanged)
        self.refreshControl = refresh
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
//
     override func prepare(for segue: UIStoryboardSegue!, sender: Any?) {
        var nextVC = segue.destination as? ViewController
        nextVC?.connectedTo = self.globalPeripheralName
    }


    // MARK: ======= Table view data source ======

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bleShield.peripherals.count
    }
    
    @objc func scanForDevices() {
        print("Scanning for devices...")
        // disconnect from any peripherals
        for peripheral in bleShield.peripherals {
            if(peripheral.state == .connected){
                bleShield.disconnectFromPeripheral(peripheral: peripheral)
            }
        }
        
        //start search for peripherals with a timeout of 3 seconds
        // this is an asynchronous call and will return before search is complete
        if(bleShield.startScanning(timeout: 3.0)){
            // after three seconds, try to connect to first peripheral
            Timer.scheduledTimer(withTimeInterval: 3.0,
                                 repeats: false,
                                 block: self.didFinishScanning)
        }
        
    }
    
    func didFinishScanning(timer:Timer){
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)

        let peripheral = self.bleShield.peripherals[indexPath.row]
        print("peripheral name: ", peripheral.name!)
        cell.textLabel?.text = peripheral.name!
        cell.detailTextLabel?.text = peripheral.identifier.uuidString

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var peripheral = self.bleShield.peripherals[indexPath.row]
        
        // MARK: CHANGE 6: add code heblre to connect to the selected peripheral
        
//        if(bleShield.peripherals.name == peripheral.name) {
        // can put in block of code andd run in 100 ms
        print("peripheral: ", peripheral)
        self.bleShield.connectToPeripheral(peripheral: peripheral)
        print("connected to peripheral")
        self.globalPeripheralName = peripheral.name!
        print("global: ", self.globalPeripheralName)
        //}
    }

}
