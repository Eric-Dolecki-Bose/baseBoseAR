//
//  ViewController.swift
//  baseBoseAR
//
//  Created by Eric Dolecki on 6/14/19.
//  Copyright © 2019 Eric Dolecki. All rights reserved.
//

import UIKit
import BoseWearable

class ViewController: UIViewController {

    var session: WearableDeviceSession?
    let sensorDispatch = SensorDispatch(queue: .main)
    var token: ListenerToken?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        sensorDispatch.handler = self
        
        BoseWearable.shared.startDeviceSearch(mode: .alwaysShowUI) { result in
            switch result {
            case .success(let session):
                print("Success connecting to Bose AR device.")
                self.session = session
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            case .cancelled:
                print("cancelled")
                break
            }
        }
    }
}

