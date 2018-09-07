//
//  WKWebViewDemo.swift
//  TestDemo
//
//  Created by Chivalrous on 2018/9/7.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

import Foundation
import WebKit

class WKWebViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainView()
    }
    
    //MARK: -- lazy
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration.init()
        let webView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
}

extension WKWebViewController {
    
    //MARK: -- 加载界面
    fileprivate func loadMainView() {
        view.addSubview(webView)
    }
}

extension WKWebViewController: WKNavigationDelegate, WKUIDelegate {
    
    
}
