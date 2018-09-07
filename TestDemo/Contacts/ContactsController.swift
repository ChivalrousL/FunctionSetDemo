//
//  ContactsController.swift
//  TestDemo
//
//  Created by Chivalrous on 2018/9/5.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

import Foundation
import UIKit

class ContactsController: UIViewController {
    
    var contacts: [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainView()
    }
    
    //MARK: -- lazy
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
}

extension ContactsController {
    
    //MARK: -- 加载界面
    fileprivate func loadMainView() {
        view.addSubview(tableView)
    }
    
    //MARK: -- 弹窗显示电话号码
    fileprivate func alert(contacts: [[String: Any]]) {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        for contact in contacts {
            var typeStr = ""
            if let label = contact["label"] as? String {
                typeStr = label
            }
            var phoneStr = ""
            if let phone = contact["phone"] as? String {
                phoneStr = phone
            }
            let alertAction = UIAlertAction.init(title: "\(typeStr): \(phoneStr)", style: .default) { (action) in
                self.call(phone: phoneStr)
            }
            alert.addAction(alertAction)
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: -- 拨打电话操作
    fileprivate func call(phone: String) {
        if phone.isEmpty {
            return
        }
        if let phoneUrl = URL.init(string: phone) {
            if UIApplication.shared.canOpenURL(phoneUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(phoneUrl)
                }
            }
        }
    }
}

extension ContactsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "ContactsCell")
        }
        let contact = contacts![indexPath.row]
        var firstName = ""
        var middleName = ""
        var lastName = ""
        var organizationName = ""
        if let firstname = contact["first_name"] as? String {
            firstName = firstname
        }
        if let middlename = contact["middle_name"] as? String {
            middleName = middlename
        }
        if let lastname = contact["last_name"] as? String {
            lastName = lastname
        }
        if let organization = contact["organization"] as? String {
            organizationName = organization
        }
        cell?.textLabel?.text = "姓名: \(firstName)\(middleName)\(lastName)"
        cell?.detailTextLabel?.text = "公司: \(organizationName)"
        cell?.accessoryType = .disclosureIndicator
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = contacts![indexPath.row]
        if let phones = contact["phones"] as? [[String: Any]] {
            alert(contacts: phones)
        }
    }
}
