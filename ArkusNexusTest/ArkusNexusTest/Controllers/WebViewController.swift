//
//  WebViewController.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var url_site: String!

    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeColorStatusBar(view: self.view)
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height - 0.0)
        view.addSubview(webView)
        
        
        self.Activity.hidesWhenStopped = true
        webView.isHidden = false
        let url = URL(string: url_site)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        self.Activity.startAnimating()
        self.title = "Website"
    }
    
    @IBAction func actionBack(_ sender: Any) {
               self.dismiss(animated: true, completion: nil)
     }
             
     override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         Activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         Activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         Activity.stopAnimating()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Activity.stopAnimating()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}

