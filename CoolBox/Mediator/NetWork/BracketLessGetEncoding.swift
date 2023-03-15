//
//  BracketLessGetEncoding.swift
//  huandian
//
//  Created by Jhin on 2020/9/15.
//  Copyright © 2020 immotor. All rights reserved.
//

import Alamofire

struct BracketLessGetEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
        return request
    }
}
