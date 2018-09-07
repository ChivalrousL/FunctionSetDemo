//
//  ViewController.swift
//  TestDemo
//
//  Created by Chivalrous on 2018/9/4.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: -- lazy
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            
            tableView.mj_header.endRefreshing()
        })
        return tableView
    }()
    
    fileprivate lazy var testList: [String] = {
        let testList = ["Contacts", "In-App Purchase"]
        return testList
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    //MARK: -- 加载界面
    fileprivate func loadMainView() {
        view.backgroundColor = .white
        title = "首页"
        view.addSubview(tableView)
    }
    
    //MARK: -- 交互事件处理
    fileprivate func userAction(index: Int) {
        switch index {
        case 0:
            ContactsManager.shared.contactAuth(success: { (bookList) in
                print("用户通讯录获取完成")
                let contacts = ContactsController()
                contacts.contacts = bookList
                contacts.title = self.testList[index]
                self.navigationController?.pushViewController(contacts, animated: true)
            }) {
                print("用户通讯录获取失败")
            }
            break
        case 1:
            IAPManager.shared.start(purchaseIds: ["product_001"])
            break
        default:
            break
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")!
        cell.textLabel?.text = testList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        userAction(index: indexPath.row)
    }
}

