//
//  WebViewViewController.swift
//  ARKitBussinessCard
//
//  Created by sun on 11/5/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var WebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://github.com/sun-23")
        WebView.loadRequest(URLRequest(url: url!))
    }
    

    @IBAction func Back(_ sender: UIButton) {
        
        performSegue(withIdentifier: "BackToAR", sender: nil)
    }
    

}
