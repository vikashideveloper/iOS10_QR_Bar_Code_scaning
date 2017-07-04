//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Vikash Kumar on 28/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var scannerCompletionBlock: (String)-> Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorizationForCameraAccess()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }

    //prepare capturing session.
    func prepareScanner() {
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var deviceInput: AVCaptureDeviceInput
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let err{
            return print(err.localizedDescription)
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            return print("Your device does not support scanning a code from an item. Please use a device with a camera")
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        let scanAreaView = UIView()
        scanAreaView.layer.borderColor = UIColor.red.cgColor
        scanAreaView.backgroundColor = UIColor.clear
        scanAreaView.layer.borderWidth = 2.5
        scanAreaView.frame.size = CGSize(width: 300, height: 250)
        scanAreaView.center = self.view.center
        let scanRect = scanAreaView.frame

        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]

        } else  {
            return print("Your device does not support scanning a code from an item. Please use a device with a camera")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        metaDataOutput.rectOfInterest = previewLayer.metadataOutputRectOfInterest(for: scanRect)
        self.view.addSubview(scanAreaView)
    }
    
    //request authorization for camera access.
    func requestAuthorizationForCameraAccess() {
        let deviceType = AVMediaTypeVideo
        let status = AVCaptureDevice.authorizationStatus(forMediaType: deviceType)
        switch status {
        case .authorized:
            prepareScanner()
        case .denied:
            
            break
            
        default:
            AVCaptureDevice.requestAccess(forMediaType: deviceType, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.prepareScanner()
                    }
                }
            })
        }
    }
}

//Capture metadata output delegate.
extension ScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print(readableObject.stringValue)
            scannerCompletionBlock(readableObject.stringValue)
            self.dismiss(animated: true, completion: nil)
        }
    

    }
}


