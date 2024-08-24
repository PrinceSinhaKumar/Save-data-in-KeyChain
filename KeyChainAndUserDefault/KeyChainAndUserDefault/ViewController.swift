//
//  ViewController.swift
//  KeyChainAndUserDefault
//
//  Created by  Prince Shrivastav on 25/08/24.
//

import UIKit

class ViewController: UIViewController {
    
    let keyChainItem = KeychainItem(service: "Account", account: "test@gmail.com")
    fileprivate func toSave() {
        keyChainItem.secureValue = "123456789"
    }
    fileprivate func toGet()  -> String? {
        return keyChainItem.secureValue
    }
    
    fileprivate func toDelete(){
        keyChainItem.secureValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toSave()
        print(toGet())
    }


}

class KeychainItem {
    let service: String
    let account: String
    
    init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    var secureValue: String? {
        get {
            return Keychain.load(service: service, account: account)
        }
        set {
            if let newValue = newValue {
                Keychain.save(service: service, account: account, value: newValue)
            } else {
                Keychain.delete(service: service, account: account)
            }
        }
    }
}

class Keychain {
    class func load(service: String, account: String) -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
        
        if status == errSecSuccess {
            return String(data: result as! Data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    class func save(service: String, account: String, value: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    class func delete(service: String, account: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
}

