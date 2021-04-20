//
//  File.swift
//  
//
//  Created by Rubens Machion on 14/04/21.
//

import Foundation

@_exported import RSA

public typealias CallBackGenerateHash = ((_ hash: String?, _ error: Error?)->())

struct JSON: Codable {
    var date_created: String!
    var id: Int64!
    var ip: String!
    var public_key: String!
}

enum Errors: String {
    case invalidPublicKey
    case invalidURL
    
    func code() -> Int {
        switch self {
        case .invalidPublicKey:
            return 100
        case .invalidURL:
            return 101
        }
    }
    
    func description() -> String {
        switch self {
        case .invalidPublicKey:
            return "null or inválid public key"
        case .invalidURL:
            return "null or inválid URL base"
        }
    }
    
    func userInfo() -> [String : Any] {
        return self.createUserInfo()
    }
    
    private func createUserInfo() -> [String : Any] {
        
        let userInfo: [String : Any] = [
            "key" : self.rawValue,
            "description" : self.description(),
            "code" : self.code()
        ]
        
        return userInfo
    }
}

// MARK: - CreditCard Protocol
public protocol PagarMeCreditCardProcotol: class {
    var number: String! { get }
    var holderName: String! { get }
    var expirationDate: String! { get }
    var cvv: String! { get }
    
    init(number: String, holderName: String, expirationDate: String, cvv: String)
    func generateHash(completion: @escaping CallBackGenerateHash)
    func getCardHashString() -> String
}


// MARK: - CreditCard
public class PagarMeCreditCard: PagarMeCreditCardProcotol {
    
    public var number: String!
    public var holderName: String!
    public var expirationDate: String!
    public var cvv: String!
    
    public required init(number: String, holderName: String, expirationDate: String, cvv: String) {
        self.number = number
        self.holderName = holderName
        self.expirationDate = expirationDate
        self.cvv = cvv
    }
    
    public func generateHash(completion: @escaping CallBackGenerateHash) {
        
        guard let publicKey = EncryptionKey.shared.key else {
            completion(nil, NSError(domain: Errors.invalidPublicKey.description(),
                                    code: Errors.invalidPublicKey.code(),
                                    userInfo: Errors.invalidPublicKey.userInfo()))
            return
        }
        
        var urlComponent = URLComponents(string: PagarMeEndpoint.Path.Transaction.cardHashKey.endpoint())
        urlComponent?.queryItems = [URLQueryItem(name: "encryption_key", value: publicKey)]
        
        guard let url = urlComponent?.url else {
            completion(nil, NSError(domain: Errors.invalidPublicKey.description(),
                                    code: Errors.invalidPublicKey.code(),
                                    userInfo: Errors.invalidPublicKey.userInfo()))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            
            if let e = error {
                completion(nil, e)
            } else {
                guard let d = data,
                      let jsonString = String(data: d, encoding: .utf8) else {
                    return
                }
                
                if let json = self.decodeDic(json: jsonString) {
                    
                    let cardString = self.getCardHashString()
                    let encryptedStr = RSA.encryptString(cardString, publicKey: json.public_key!)
                    let final = "\(json.id!)_\(encryptedStr)"
                    
                    completion(final, nil)
                    
                } else {
                    print("Error")
                    completion(nil, nil)
                }
            }
            
        }.resume()
    }
    
    public func getCardHashString() -> String {
        
        let r = [
            String(format: "card_number=%@", self.number!),
            String(format: "card_holder_name=%@", self.holderName!),
            String(format: "card_expiration_date=%@", self.expirationDate),
            String(format: "card_cvv=%@", self.cvv!)
        ]
        
        return r.joined(separator: "&")
    }
}

extension PagarMeCreditCard {
    
    func decodeDic(json: String) -> JSON? {
        
        guard let _json = json.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        if let result = try? decoder.decode(JSON.self, from: _json) {
            return result
        } else {
            return nil
        }
    }
}
