//
//  Keychain.swift
//  Scrap
//
//  Created by 김영선 on 2023/01/05.
//

import Foundation
import Security

final class Keychain {
    private let account = "UserData"
    private let service = Bundle.main.bundleIdentifier
    
    //query 객체 생성
    private lazy var query: [CFString: Any]? = { //lazy stored property
        guard let service = self.service else { return nil }
        return [kSecClass: kSecClassGenericPassword,
          kSecAttrService: service,
          kSecAttrAccount: account]
    }()
    
    // MARK: - Store the item(name, email, identifier) in Keychain
    // DataType(UserData) 타입의 저장할 아이템(userData)가 파라미터로 넘어온다.
    // SecItemAdd() -> create keyChain item & if success, return true
    func storeUserData(_ user: UserData) -> Bool {
        print("✅ ready to store user data")
        guard let data = try? JSONEncoder().encode(user),       //데이터 암호화
              let service = self.service else {
            print("error: encoding data? or service")
            return false
        }
        let query: [CFString:Any] = [kSecClass: kSecClassGenericPassword,
                               kSecAttrService: service,
                               kSecAttrAccount: account,
                               kSecAttrGeneric: data] //저장할 아이템 데이터
        print(query)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    // MARK: - Read the item(name, email, identifier) in Keychain
    // 사용자 데이터 반환
    // SecItemCopyMatching() -> inquiry keychain item & if success, return UserData
    func readUserData() -> UserData? {
        print("✅ ready to read user data")
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: service as Any,
                                    kSecAttrAccount: account,
                                    kSecMatchLimit: kSecMatchLimitOne, //최대 결과 수
                                    kSecReturnAttributes: true,        //return CFDictionary
                                    kSecReturnData: true ]             //return CFData
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess {
            print("🚨 fail at SecItemCopyMatching")
            return nil
        }
        guard let existingItem = item as? [CFString: Any],
              let data = existingItem[kSecAttrGeneric] as? Data,
              let user = try? JSONDecoder().decode(UserData.self, from: data) else {
            print("🚨 fail to assign existingITem or data or decoding user")
            return nil
        }
        print(user)
        return user
    }
    
    // MARK: - Delete Keychain item
    // SecItemDelete() -> delete keychain item & if success, return true
    func deleteUserData() -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service as Any,
                                kSecAttrAccount: account]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
