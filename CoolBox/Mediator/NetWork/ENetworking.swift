//
//  ENetWork.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import Foundation
@_exported import Moya
@_exported import SwiftyJSON

let AppNeedLoginNotificationKey = NSNotification.Name(rawValue: "AppNeedLoginNotificationKey")

struct ENetworking {
    enum ResultCode: Int {
        case success = 200
        case needLogin = 202
        case failure = 0
    }
    
    typealias SuccessClosure = (JSON) -> Void
    typealias FailureClosure = (MoyaError, JSON?) -> Void
    typealias DownloadClosure  = (_ filePath: URL) -> Void
    typealias RedirectClosure  = (Response) -> Void
    typealias PrograssClosure  = (Double, Bool) -> Void
    
    static func request(_ target: ETargetType) {
        request(target, success: { (_) in }) { (_, _) in }
    }
    
    static func redirectRequest(_ target: ETargetType, redirect: @escaping RedirectClosure) {
        ENetworkingAdapt.provider.request(MultiTarget(target)) { result in
            ENetworking.redirectHandleResult(result, redirect: redirect)
        }
    }
    
    static func request(_ target: ETargetType, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        ENetworkingAdapt.provider.request(MultiTarget(target)) { result in
            ENetworking.handleResult(result, success: success, failure: failure)
        }
    }
    
    static func uploadRequest(_ target: ETargetType, prograss: @escaping PrograssClosure, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        ENetworkingAdapt.provider.request(MultiTarget(target)) { (progressResponse) in
            ENetworking.prograssHandleResult(progressResponse, prograss: prograss)
        } completion: { result in
            ENetworking.handleResult(result, success: success, failure: failure)
        }
    }
    
    private static func prograssHandleResult(_ response:ProgressResponse,  prograss: @escaping PrograssClosure) {
        prograss(response.progress, response.completed)
    }
    
    private static func handleResult(_ result: Result<Moya.Response, MoyaError>, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        switch result {
        case let .success(moyaResponse):
            do {
                let json = try JSON(moyaResponse.mapJSON())
                guard let codeValue = json["code"].int,
                      let code = ResultCode(rawValue: codeValue) else {
                    return failure(MoyaError.statusCode(moyaResponse), json)
                }
                if code == .success {
                    success(json["result"])
                }
                else if code == .needLogin {
                    EToast.showFailed(json["message"].stringValue)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        NotificationCenter.default.post(name: AppNeedLoginNotificationKey, object: json)
                    }
                }
                else {
                    failure(MoyaError.statusCode(moyaResponse), json)
                    EToast.showFailed(json["message"].stringValue)
                }
                
            } catch {
                failure(MoyaError.statusCode(moyaResponse), JSON(["message": "JSON 解析错误"]))
                EToast.showFailed("JSON 解析错误")
            }
        case let .failure(error):
            failure(error, JSON(["message": "网络错误"]))
        }
    }
    
    private static func redirectHandleResult(_ result: Result<Moya.Response, MoyaError>, redirect: @escaping RedirectClosure) {
        switch result {
        case let .success(moyaResponse):
            redirect(moyaResponse)
        default: break
        }
    }
    
    static func download(_ asset: String, success: @escaping DownloadClosure) -> Cancellable? {
        return download(asset, success: success) { (_,_) in }
    }
    
    static func download(_ asset: String, success: @escaping DownloadClosure, failure: @escaping FailureClosure) -> Cancellable? {
        let target = EAsset.download(url: asset)
        
        if FileManager.default.fileExists(atPath: target.localLocation.path) {
            success(target.localLocation)
            return nil
        }
        
        return ENetworkingAdapt.provider.request(MultiTarget(target)) { result in
            switch result {
            case .success: success(target.localLocation)
            case let .failure(error): return failure(error, nil)
            }
        }
    }
}

fileprivate struct ENetworkingAdapt {
    
    static let deviceInfo = EApiConfig.deviceName()
    static let os = "iOS " + UIDevice.current.systemVersion
    static let appVersion = EApiConfig.getAppVersion()
    static let apiVersion = "v1"
    static let deviceId = EApiConfig.uuidStringMD5()
    
    static let HTTPHeaderFields: [String: String] = [
        "os": os,
        "deviceInfo": deviceInfo,
        "appVersion": appVersion,
        "apiVersion": apiVersion,
        "deviceId" : deviceId,
        "channel": "ios"
    ]
    
    static let endpointClosure = { (target: MultiTarget) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        var newEndpoint = defaultEndpoint.adding(newHTTPHeaderFields: HTTPHeaderFields)
        if let headers = target.headers {
            newEndpoint = newEndpoint.adding(newHTTPHeaderFields: headers)
            //防止Content-type被覆盖
            if let hasContentType = newEndpoint.httpHeaderFields?.keys.contains("Content-Type"), !hasContentType {
                newEndpoint = newEndpoint.adding(newHTTPHeaderFields: ["Content-Type" : "application/json"])
            }
        }
        if let token = EApiConfig.appToken() {
            newEndpoint = newEndpoint.adding(newHTTPHeaderFields: ["AccessToken": token])
        }
        return newEndpoint
    }
    
    static let requestClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<MultiTarget>.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            request.timeoutInterval = 90
            done(.success(request))
        } catch MoyaError.requestMapping(let url) {
            done(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            done(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    static let sendAndReceivePlugin = NetworkActivityPlugin { (changeType, target) in
        DispatchQueue.main.async(execute: {
            switch changeType {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                #if DEBUG
                
                #endif
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    static let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure,
                                                    requestClosure: requestClosure,
                                                    plugins: [sendAndReceivePlugin])
}

extension ENetworking {
    
    /// sign = sha256(md5(authorization) + md5(sort(body)) + timestamp)
    /// authorization = EApiConfig.appToken()
    ///
    /// - Parameters:
    ///   - body: post 请求参数
    ///   - timestamp: 当前请求时间戳(秒)
    ///
    static func sign(body: [String: Any],
                     timestamp: Int) -> String? {
        guard let authorization = EApiConfig.appToken() else { return nil }
        let jsonMD5 = body.sortedJsonString().md5
        return (authorization.md5 + jsonMD5 + "\(timestamp)").sha256
    }
    
    static func timestamp() -> Int {
        let date = Date(timeIntervalSinceNow: 0)
        let timestamp: TimeInterval = date.timeIntervalSince1970
        return Int(timestamp) * 1000 // 毫秒
    }
    
    
}
