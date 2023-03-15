//
//  ETargetType.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import Moya

protocol ETargetType: TargetType {
    var parameters: [String: Any]? { get }
    
    /// 是否需要加签
    ///
    /// 加签对应的参数
    /// Authorization             --用户 token (JWT Token)
    /// timestamp                  --当前 UTC 时间戳（秒）
    /// body                           --post 请求体
    ///
    /// 加签过程
    /// sign = sha256(md5(Authorization) + md5(sort(body)) + timestamp)
    ///
    /// header 除Authorization 之外，需要添加 timestamp，sign
    var needSign: Bool { get }
}

typealias Method = Moya.Method
extension ETargetType {
    var baseURL: URL {
        guard let url = URL(string: EApiConfig.baseUrl()) else {
            fatalError("EApiConfig.setApp(url:, authorization:), url is invalid")
        }
        return url
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        switch self.method {
        case .post, .patch, .put:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: encoding)
        }
        return .requestPlain
    }
    
    var needSign: Bool {
        return false
    }
}

fileprivate let assetDir: URL = {
    let fileCaches = "huandian-file-caches"
    guard var cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        var url = URL(fileURLWithPath: NSTemporaryDirectory())
        return url
    }
    cacheUrl.appendPathComponent(fileCaches)
    if !FileManager.default.fileExists(atPath: cacheUrl.path) {
        do {
            try FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {}
    }
    return cacheUrl
}()

enum EAsset: ETargetType {
    
    case download(url: String)
    
    var path: String { return "" }
    
    var baseURL: URL {
        switch self {
        case .download(let url):
            guard let url = URL(string: url) else {
                fatalError("download(let url), url is invalid")
            }
            return url
        }
    }
    
    private var assetName: String {
        switch self {
        case .download(let url): return EApiConfig.md5For(string: url)
        }
    }
    
    var localLocation: URL {
        return assetDir.appendingPathComponent(assetName)
    }
    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, .removePreviousFile) }
    }
    
    var task: Task {
        return .downloadDestination(downloadDestination)
    }
}

