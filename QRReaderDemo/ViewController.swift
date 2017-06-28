//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Vikash Kumar on 28/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lblResult: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scannerSegue" {
            let scannerVC = segue.destination as! ScannerViewController
            scannerVC.scannerCompletionBlock = { resultStr in
                self.lblResult.text = resultStr
            }
        }
    }
}
