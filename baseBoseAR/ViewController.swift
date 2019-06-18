//
//  ViewController.swift
//  baseBoseAR
//
//  Created by Eric Dolecki on 6/14/19.
//  Copyright © 2019 Eric Dolecki. All rights reserved.
//

import UIKit
import BoseWearable
import Foundation
import AVFoundation

class ViewController: UIViewController, WearableDeviceSessionDelegate, SensorDispatchHandler
{
    var session: WearableDeviceSession!
    private let sensorDispatch = SensorDispatch(queue: .main)
    private var token: ListenerToken?
    @IBOutlet weak var pitchLabel: UILabel!
    var device: WearableDevice? { return session.device }
    var goodSoundEffect: AVAudioPlayer?
    var badSoundEffect: AVAudioPlayer?
    var playedWhichSound = "none"
    var womanHead: UIImageView!
    var degreeLabel: UILabel!
    var cover: UIView!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        womanHead = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        womanHead.image = UIImage(named: "head2")
        womanHead.contentMode = .scaleAspectFit
        womanHead.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        womanHead.layer.cornerRadius = womanHead.frame.height / 2
        womanHead.layer.borderColor = UIColor.black.cgColor
        womanHead.layer.masksToBounds = true
        womanHead.layer.borderWidth = 1.0
        womanHead.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.height - 175)
        self.view.addSubview(womanHead)
        
        degreeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        degreeLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
        degreeLabel.textColor = UIColor.black
        degreeLabel.textAlignment = .center
        degreeLabel.center = CGPoint(x: self.view.frame.midX, y: womanHead.center.y + womanHead.frame.height / 2 + 10)
        self.view.addSubview(degreeLabel)
        
        cover = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        cover.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cover.layer.cornerRadius = 50
        cover.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        cover.layer.borderWidth = 3.0
        cover.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.center = CGPoint(x: cover.frame.width / 2, y: cover.frame.height / 2)
        
        cover.addSubview(spinner)
        cover.isHidden = true
        self.view.addSubview(cover)
        
        startSearch()
    }
    
    func startSearch()
    {
        BoseWearable.shared.startDeviceSearch(mode: .alwaysShowUI) { result in
            switch result {
                
            case .success(let session):
                
                self.cover.isHidden = false
                self.spinner.startAnimating()
                
                self.session = session
                self.session.delegate = self
                
                // When actually opened, we set up sensors and gestures.
                
                self.session.open()
                self.sensorDispatch.handler = self
                
            case .failure(let error):
                print("failure \(error.localizedDescription)")
                
            case .cancelled:
                print("cancelled.")
            }
        }
    }
    
    private func configureGestures()
    {
        session.device?.configureGestures { config in
            config.disableAll()
            config.set(gesture: .headNod, enabled: true)
            config.set(gesture: .headShake, enabled: true)
            config.set(gesture: .doubleTap, enabled: true)
            config.set(gesture: .singleTap, enabled: true)
            print("Headshake: \(config.isEnabled(gesture: .headShake))")    //false
            print("Head Nod: \(config.isEnabled(gesture: .headNod))")       //false
            print("2x Tap: \(config.isEnabled(gesture: .doubleTap))")       //true
            print(session.device?.gestureInformation?.availableGestures as Any)
            print(session.device?.wearableDeviceInformation as Any)
        }
    }
    
    func listenForWearableDeviceEvents() {
        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }
    
    private func listenForSensors() {
        session.device?.configureSensors { config in
            config.disableAll()
            config.enable(sensor: .gameRotation, at: ._20ms)
        }
    }
    
    private func wearableDeviceEvent(_ event: WearableDeviceEvent)
    {
        switch event {
        case .didFailToWriteSensorConfiguration(let error):
            print("Couldn't set configuration error: \(error)")
            
        case .didSuspendWearableSensorService:
            print("sensor suspended.")
            
        case .didResumeWearableSensorService:
            print("sensor resumed.")
        
        case .didUpdateSensorConfiguration(let config):
            print("Updated sensor configuration. Enabled:\(config.enabledSensors)")
        
        case .didFailToWriteGestureConfiguration(let error):
            print("Failed to write gesture config. \(error.localizedDescription)")
            
        default:
            break
        }
    }
    
    func sessionDidOpen(_ session: WearableDeviceSession)
    {
        print("Session did open.")
        
        //Now that we have a session, let's set up the device to get events.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.configureGestures()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.cover.isHidden = true
            self.spinner.stopAnimating()
        })
        
        self.listenForSensors()
        self.listenForWearableDeviceEvents()
    }
    
    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        print("Session open error: \(error!)")
    }
    
    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        if error != nil {
            print("Session closed error: \(error!)")
            if (error?.localizedDescription.contains("disconnected from us"))! {
            //if error?.localizedDescription == "The specified device has disconnected from us." {
                let alert = UIAlertController(title: "Disconnected", message: "Your Bose AR device has disconnected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func receivedGesture(type: GestureType, timestamp: SensorTimestamp)
    {
        switch type {
        case .doubleTap:
            print("double-tap.")
        case .headNod:
            print("head nod.")
        case .headShake:
            print("head shake.")
        case .singleTap:
            print("single tap.")
        }
    }
    
    // Is the blind user's head up too much? Too low?
    func receivedGameRotation(quaternion: Quaternion, timestamp: SensorTimestamp)
    {
        let thisPitch = quaternion.pitch
        let deg = Double(thisPitch * 180 / .pi)
        degreeLabel.text = "\(format(degrees:deg))"
        let simplified = -thisPitch / 1
        womanHead.transform = CGAffineTransform(rotationAngle: CGFloat(simplified))
        
        if thisPitch >  0.3 || thisPitch < -0.2
        {
            self.pitchLabel.text = "BAD"
            self.pitchLabel.textColor = UIColor.white
            self.view.backgroundColor = UIColor.red
            if playedWhichSound != "bad"
            {
                playSoundEffect(isGood: false)
                playedWhichSound = "bad"
            }
            
        } else {
            self.pitchLabel.text = "GOOD"
            self.view.backgroundColor = UIColor.green
            self.pitchLabel.textColor = UIColor.black
            if playedWhichSound != "good"
            {
                playSoundEffect(isGood: true)
                playedWhichSound = "good"
            }
        }
    }
    
    func playSoundEffect(isGood g:Bool) {
        if g
        {
            let path = Bundle.main.path(forResource: "positive.wav", ofType: nil)
            let url = URL(fileURLWithPath: path!)
            do {
                goodSoundEffect = try AVAudioPlayer(contentsOf: url)
                goodSoundEffect?.play()
            } catch {
                // Could not load the file.
            }
        } else {
            let path = Bundle.main.path(forResource: "negative.wav", ofType: nil)
            let url = URL(fileURLWithPath: path!)
            do {
                badSoundEffect = try AVAudioPlayer(contentsOf: url)
                badSoundEffect?.play()
            } catch {
                // Could not load the file.
            }
        }
    }

    //MARK: - Utilities.
    
    /// Utility to format radians as degrees with two decimal places and a degree symbol.
    func format(radians: Double) -> String {
        let degrees = radians * 180 / Double.pi
        return String(format: "%.02f°", degrees)
    }
    
    /// Utility to format radians as degrees with two decimal places and a degree symbol.
    func format(radians: Float) -> String {
        let degrees = radians * 180 / Float.pi
        return String(format: "%.02f°", degrees)
    }
    
    /// Utility to format degrees with two decimal places and a degree symbol.
    func format(degrees: Double) -> String {
        return String(format: "%.02f°", degrees)
    }
    
    /// Utility to format a double with four decimal places.
    func format(decimal: Double) -> String {
        return String(format: "%.04f", decimal)
    }
    
    /// Converts the byte sequence of this Data object into a hexadecimal representation (two lowercase characters per byte).
    func format(data: Data?) -> String? {
        return data?.map({ String(format: "%02hhX", $0) }).joined()
    }
}
