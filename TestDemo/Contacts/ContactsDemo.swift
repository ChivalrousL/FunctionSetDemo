//
//  ContactsDemo.swift
//  TestDemo
//
//  Created by Chivalrous on 2018/9/5.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import AddressBook

class ContactsManager: NSObject {
    
    static let shared = ContactsManager.init()
    
    lazy var contactBookRef = ABAddressBookCreate() as ABAddressBook
    @available(iOS 9.0, *)
    lazy var contactStore = CNContactStore.init()
    
    override init() {
        super.init()
    }
}

extension ContactsManager {
    
    //MARK: -- 获取用户授权
    func contactAuth(success: @escaping(([[String: Any]]) -> ()), failed: @escaping(() -> ())) {
        DispatchQueue.main.async { //授权操作仅在主线程内执行
            //获取授权状态
            let authStatus = self.contactAuthStatus()
            if authStatus == 0 { //尚未选择授权
                //初始化信号量
                let sem = DispatchSemaphore.init(value: 0)
                if #available(iOS 9.0, *) {
                    //请求用户选择授非即时行为,此处阻塞线程等待用户选择完成后再执行下一步任务
                    self.contactStore.requestAccess(for: .contacts) { (isRight, error) in
                        if isRight {
                            print("授权成功,开始获取通讯录")
                            self.getAddressBook(success: { (bookList) in
                                success(bookList)
                            }, falied: {
                                failed()
                            })
                        } else {
                            print("授权失败")
                            failed()
                        }
                        sem.signal()
                    }
                } else {
                    //请求用户选择授非即时行为,此处阻塞线程等待用户选择完成后再执行下一步任务
                    ABAddressBookRequestAccessWithCompletion(self.contactBookRef, { (isRight, error) in
                        if isRight {
                            print("授权成功,开始获取通讯录")
                            self.getAddressBook(success: { (bookList) in
                                success(bookList)
                            }, falied: {
                                failed()
                            })
                        } else {
                            print("授权失败")
                            failed()
                        }
                        sem.signal()
                    })
                }
                //信号量等待
                sem.wait()
            } else if authStatus == 1 || authStatus == 2 { //用户拒绝 & 因其他原因导致授权不可用
                let alert = UIAlertController.init(title: "您已拒绝访问通讯录,请先至设置页面授权", message: nil, preferredStyle: .alert)
                let confirmAction = UIAlertAction.init(title: "去设置", style: .cancel) { (action) in
                    if let contactUrl = URL.init(string: UIApplicationOpenSettingsURLString) {
                        if UIApplication.shared.canOpenURL(contactUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(contactUrl, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(contactUrl)
                            }
                        }
                    }
                }
                alert.addAction(confirmAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                failed()
            } else if authStatus == 3 { //成功授权
                self.getAddressBook(success: { (bookList) in
                    success(bookList)
                }, falied: {
                    failed()
                })
            }
        }
    }
    
    //MARK: -- 获取用户通讯录当前授权状态
    fileprivate func contactAuthStatus() -> Int {
        if #available(iOS 9.0, *) {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .notDetermined:
                return 0 //未选择授权
            case .restricted:
                return 1 //因其他原因导致授权不可用
            case .denied:
                return 2 //用户拒绝
            case .authorized:
                return 3 //用户已同意授权
            }
        } else {
            switch ABAddressBookGetAuthorizationStatus() {
            case .notDetermined:
                return 0 //未选择授权
            case .restricted:
                return 1 //因其他原因导致授权不可用
            case .denied:
                return 2 //用户拒绝
            case .authorized:
                return 3 //用户已同意授权
            }
        }
    }
    
    //MARK: -- 获取通讯录信息
    fileprivate func getAddressBook(success: @escaping(([[String: Any]]) -> ()), falied: @escaping(() -> ())) {
        if #available(iOS 9.0, *) { //iOS >= 9.0
            //设定检索条件
            let fetch = [
                CNContactGivenNameKey as CNKeyDescriptor, //名字
                CNContactFamilyNameKey as CNKeyDescriptor, //姓氏
                CNContactMiddleNameKey as CNKeyDescriptor, //中间名
                CNContactOrganizationNameKey as CNKeyDescriptor, //公司名字
                CNContactPhoneNumbersKey as CNKeyDescriptor, //电话号码
            ]
            //生成检索请求对象
            let request = CNContactFetchRequest.init(keysToFetch: fetch)
            //通讯录总数据
            var bookList = [[String: Any]]()
            DispatchQueue.global().async { //检索为耗时操作
                do {
                    //执行检索
                    try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, obj) in
                        var phoneList = [[String: Any]]()
                        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                            for value in contact.phoneNumbers {
                                //电话号码类型
                                var typeStr = value.label ?? ""
                                typeStr = typeStr.replacingOccurrences(of: "_$!<", with: "")
                                typeStr = typeStr.replacingOccurrences(of: ">!$_", with: "")
                                typeStr = typeStr.replacingOccurrences(of: " ", with: "")
                                //电话号码
                                var phoneStr = value.value.stringValue
                                phoneStr = phoneStr.replacingOccurrences(of: "-", with: "")
                                phoneList.append(["phone": phoneStr, "label": typeStr])
                            }
                        }
                        bookList.append(["first_name": contact.familyName, "middle_name": contact.middleName, "last_name": contact.givenName, "organization": contact.organizationName, "phones": phoneList])
                    })
                    //检索结束
                    DispatchQueue.main.async {
                        for dic in bookList {
                            print(dic)
                        }
                        success(bookList)
                    }
                } catch {
                    print("访问通讯录失败")
                    DispatchQueue.main.async {
                        falied()
                    }
                }
            }
        } else { //iOS < 9.0
            DispatchQueue.global().async {
                //获取所有联系人列表
                let recordList = ABAddressBookCopyArrayOfAllPeople(self.contactBookRef).takeRetainedValue() as [ABRecord]
                //通讯录总数据
                var bookList = [[String: Any]]()
                //检索通讯录
                for contact in recordList {
                    var firstName = ""
                    var middleName = ""
                    var lastName = ""
                    var organization = ""
                    if let firstname = ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeRetainedValue() as? String {
                        firstName = firstname
                    }
                    if let middlename = ABRecordCopyValue(contact, kABPersonMiddleNameProperty).takeRetainedValue() as? String {
                        middleName = middlename
                    }
                    if let lastname = ABRecordCopyValue(contact, kABPersonLastNameProperty).takeRetainedValue() as? String {
                        lastName = lastname
                    }
                    if let organizationname = ABRecordCopyValue(contact, kABPersonOrganizationProperty).takeRetainedValue() as? String {
                        organization = organizationname
                    }
                    //获取通讯录联系人电话
                    let phonesInfo = ABRecordCopyValue(contact, kABPersonPhoneProperty) as ABMultiValue
                    var phoneList = [[String: Any]]()
                    for index in 0..<ABMultiValueGetCount(phonesInfo) {
                        //电话号码类型
                        var typeStr = ABMultiValueCopyLabelAtIndex(phonesInfo, index).takeRetainedValue() as String
                        typeStr = typeStr.replacingOccurrences(of: "_$!<", with: "")
                        typeStr = typeStr.replacingOccurrences(of: ">!$_", with: "")
                        typeStr = typeStr.replacingOccurrences(of: " ", with: "")
                        //电话号码
                        var phoneStr = ""
                        if let value = ABMultiValueCopyValueAtIndex(phonesInfo, index).takeRetainedValue() as? String {
                            phoneStr = value
                        }
                        phoneStr = phoneStr.replacingOccurrences(of: "-", with: "")
                        phoneList.append(["phone": phoneStr, "label": typeStr])
                    }
                    bookList.append(["first_name": firstName, "middle_name": middleName, "last_name": lastName, "organization": organization, "phones": phoneList])
                }
                //通讯录获取结束
                DispatchQueue.main.async {
                    for dic in bookList {
                        print(dic)
                    }
                    success(bookList)
                }
            }
        }
    }
}
