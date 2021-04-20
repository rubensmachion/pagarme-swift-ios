//
//  File.swift
//  
//
//  Created by Rubens Machion on 14/04/21.
//

import Foundation

@_exported import RSA

// MARK: - Constants
struct PagarMeCons {
    public static var BASE_ENDPOINT: String = "https://api.pagar.me/1"
}

struct PagarMeEndpoint {
    struct Path {
        // Transactions
        enum Transaction: String {
            case cardHashKey = "/transactions/card_hash_key"
            
            func toString() -> String {
                return self.rawValue
            }
            
            func endpoint() -> String {
                let e = "\(PagarMeCons.BASE_ENDPOINT)\(self.toString())"
                return e
            }
            
            func endpoint(args: CVarArg ...) -> String {
                let s = String(format: self.endpoint(), arguments: args)
                return s
            }
        }
    }
}


public class EncryptionKey: NSObject {
    
    public var key: String!
    
    public static let shared: EncryptionKey = EncryptionKey()
    
    private override init() { }
}
