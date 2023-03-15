//
//  String+Hashes.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif

extension String {
    
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hexString(hash.makeIterator())
    }
    
    private func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
        return iterator.map { String(format: "%02x", $0) }.joined()
    }
    
    var sha256: String {
        let data = Data(self.utf8)
        if #available(iOS 13.0, *) {
            #if canImport(CryptoKit)
            return hexString(SHA256.hash(data: data).makeIterator())
            #else
            return sha256String(data)
            #endif
        }
        else {
            return sha256String(data)
        }
    }
        
    private func sha256String(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &digest)
        }
        return hexString(digest.makeIterator())
    }
}

