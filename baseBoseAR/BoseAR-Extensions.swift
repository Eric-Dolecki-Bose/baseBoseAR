//
//  MainviewController+BoseAR.swift
//  Zones
//
//  Created by Manasi Bhandare on 4/26/19.
//  Copyright © 2019 Eric Dolecki. All rights reserved.
//

import Foundation
import BoseWearable
extension ViewController: SensorDispatchHandler,  WearableDeviceSessionDelegate{
    
    // MARK: - BoseAR event management
    private func listenForWearableDeviceEvents() {
        // Listen for incoming wearable device events. Retain the ListenerToken.
        // When the ListenerToken is deallocated, this object is automatically
        // removed as an event listener.
        token = session?.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
        
    }
    
    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didFailToWriteSensorConfiguration(let error):
            // Show an error if we were unable to set the sensor configuration.
            print("Unable to set sensor configuration. \(error.localizedDescription)")
            //show(error as! UIViewController, sender: self)
            
        case .didSuspendWearableSensorService:
            // Block the UI when the sensor service is suspended.
            print("Sensor service suspended.")
            //suspensionOverlay = SuspensionOverlay.add(to: navigationController?.view)
            
        case .didResumeWearableSensorService:
            // Unblock the UI when the sensor service is resumed.
            print("Sensor service resumed.")
            //suspensionOverlay?.removeFromSuperview()
            
        default:
            break
        }
    }
    
    private func listenForSensors() {
        
        session?.device?.configureSensors { config in
            config.disableAll()
            // Enable the gameRotation
            config.enable(sensor: .gameRotation, at: ._20ms)
        }
        session?.device?.configureGestures{config in
            config.disableAll()
            config.set(gesture: .doubleTap, enabled: true)
        }
    }
    
    func stopListeningForSensors() {
        print("stopListeningForSensors")
        // Disable all sensors.
        session?.device?.configureSensors { config in
            config.disableAll()
            
        }
        session?.device?.configureGestures{ config in
            config.disableAll()
        }
    }
    
    
    // MARK: - BoseAR session management
    func sessionDidOpen(_ session: WearableDeviceSession) {
        
        title = session.device?.name
        listenForWearableDeviceEvents()
        listenForSensors()
        
        // Unblock this view controller's UI.
        //activityIndicator?.removeFromSuperview()
        //suspensionOverlay?.removeFromSuperview()
    }
    
    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        //if self.userName != "admin" {
        //    dismiss(dueTo: error)
        //}
        
        print("Session failed to open: \(error.debugDescription)")
        
        // Unblock this view controller's UI.
        //activityIndicator?.removeFromSuperview()
        //suspensionOverlay?.removeFromSuperview()
    }
    
    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // The session was closed, possibly due to an error.
        //if self.userName != "admin" {
        //    dismiss(dueTo: error, isClosing: true)
        //}
        
        print("Session did close with error: \(error.debugDescription)")
        
        
        // Unblock this view controller's UI.
        //activityIndicator?.removeFromSuperview()
        //suspensionOverlay?.removeFromSuperview()
    }
    // Error handler function called at various points in this class.  If an error
    // occurred, show it in an alert. When the alert is dismissed, this function
    // dismisses this view controller by popping to the root view controller (we are
    // assumed to be on a navigation stack).
    private func dismiss(dueTo error: Error?, isClosing: Bool = false) {
        // Common dismiss handler passed to show()/showAlert().
        
        print(#function)
        
        /*
        let popToRoot = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        // If the connection did close and it was not due to an error, just show
        // an appropriate message.
        if isClosing && error == nil {
            navigationController?.showAlert(title: "Disconnected", message: "The connection was closed", dismissHandler: popToRoot)
        }
            // Show an error alert.
        else {
            navigationController?.show(error, dismissHandler: popToRoot)
        }
        */
    }
}
