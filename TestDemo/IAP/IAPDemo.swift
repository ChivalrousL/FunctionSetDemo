//
//  IAPDemo.swift
//  TestDemo
//
//  Created by Chivalrous on 2018/9/6.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

import Foundation
import StoreKit

enum PurchaseType {
    case Success  //购买成功
    case Failed  //购买失败
    case Cancle  //取消购买
    case Denied  //不支持内购
}

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

extension IAPManager {
    
    //MARK: -- 开始内购程序
    func start(purchaseIds: [String]) {
        if purchaseIds.count > 0 {
            if SKPaymentQueue.canMakePayments() { //支持内购
                if let set = NSSet.init(array: purchaseIds) as? Set<String> {
                    let request = SKProductsRequest.init(productIdentifiers: set )
                    request.delegate = self
                    request.start()
                } else {
                    alert(type: .Failed)
                }
            } else {
                alert(type: .Denied)
            }
        }
    }
    
    //MARK: -- 内购交易完成时对商品的处理
    fileprivate func complete(transaction: SKPaymentTransaction) {
        if !transaction.payment.productIdentifier.isEmpty { //商品id不为空时向服务器验证交易状态
            verifyPurchase(transaction: transaction, isSandBox: false)
        } else {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    //MARK: -- 内购交易失败时对商品的处理
    fileprivate func failed(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            alert(type: error.code == .paymentCancelled ? .Cancle : .Failed)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    //MARK: -- 验证商品交易在服务器的状态
    fileprivate func verifyPurchase(transaction: SKPaymentTransaction, isSandBox: Bool) {
        //获取校验数据
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            do {
                let receipt = try Data.init(contentsOf: receiptUrl)
                let requestContents = ["receipt-data": receipt.base64EncodedData(options: .init(rawValue: 0))]
                do {
                    //校验凭证
                    let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))
                    //校验地址
                    var serverUrlStr = "https://buy.itunes.apple.com/verifyReceipt"
                    if isSandBox {
                        serverUrlStr = "https://sandbox.itunes.apple.com/verifyReceipt"
                    }
                    if let storeUrl = URL.init(string: serverUrlStr) {
                        //生成请求
                        let request = NSMutableURLRequest.init(url: storeUrl)
                        request.httpMethod = "POST"
                        request.httpBody = requestData
                        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init()) { (response, data, error) in
                            if error != nil {
                                self.alert(type: .Failed)
                            } else {
                                self.alert(type: .Success)
                                // 先验证正式服务器,如果正式服务器返回21007再去苹果测试服务器验证,沙盒测试环境苹果用的是测试服务器
                                //let status = "\(response!["status"])" == 0 正式服务器,验证成功
                            }
                        }
                    }
                } catch {
                    alert(type: .Failed)
                }
                
            } catch {
                alert(type: .Failed)
            }
        } else {
            alert(type: .Failed)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    //MARK: -- 交易最终状态提醒
    fileprivate func alert(type: PurchaseType) {
        switch type {
        case .Success:
            print("购买成功")
            break
        case .Failed:
            print("购买失败")
            break
        case .Cancle:
            print("已取消购买")
            break
        default:
            print("不支持使用程序内付费")
            break
        }
    }
}

extension IAPManager: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    //MARK: -- 交易队列状态发生变更时
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: //已交易完成
                complete(transaction: transaction)
                break
            case.purchasing: //在交易队列中
                break
            case .restored: //已购买
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed: //交易失败
                failed(transaction: transaction)
                break
            default:
                break
            }
        }
    }
    
    //MARK: -- 收到响应
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            var orderProduct = SKProduct.init()
            for product in response.products {
                if product.productIdentifier == "" { //取到对应的商品
                    orderProduct = product
                    break;
                }
            }
            //生成支付申请并加入支付队列
            let payment = SKPayment.init(product: orderProduct)
            SKPaymentQueue.default().add(payment)
        } else {
            print("未检索到商品信息")
        }
    }
    
    //MARK: -- 请求失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("获取商品列表失败")
    }
    
    //MARK: -- 请求结束
    func requestDidFinish(_ request: SKRequest) {
        print("请求结束")
    }
}
