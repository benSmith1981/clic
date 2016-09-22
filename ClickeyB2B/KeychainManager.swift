//
//  KeychainManager.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

final class KeychainManager {
    struct keychainKeys {
        static let clickeyPassword = "kPassword"
        static let userID = "userID"
    }

    static let sharedInstance = KeychainManager()
    
    private let keychain = KeychainSwift()
    
    private init() {}
}

//MARK: - getYonaPassword
extension KeychainManager {
    func setPassword(password: String) {
        keychain.set(password, forKey: keychainKeys.clickeyPassword)
    }
    
    func getYonaPassword() -> String? {
        guard let password = keychain.get(keychainKeys.clickeyPassword) else { return nil }
        return password
    }
}

//MARK: - USER ID
extension KeychainManager {
    func saveUserID(userID: String) {
        keychain.set(userID, forKey: keychainKeys.userID)
    }
    
    func getUserID() -> String? {
        guard let userID = keychain.get(keychainKeys.userID) else { return nil }
        return userID
    }
}

//MARK: - clear keychain
extension KeychainManager {
    func clearKeyChain() {
        keychain.clear()
    }
    
}