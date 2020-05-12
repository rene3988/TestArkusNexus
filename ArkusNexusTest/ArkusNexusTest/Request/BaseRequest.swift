//
//  BaseRequest.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON

class BaseRequest: NSObject {
    
    let apiEndpointURL =  URL_ENDPOINT
    
    var completionBlock: ((_ response: JSON?, _ error: Any?) -> ())?
    
    func path() -> String {
        return ""
    }
    
    func params() -> [String: Any]? {
        return nil
    }
    
    func method() -> HTTPMethod {
        return HTTPMethod.get
    }
    
    func headers() -> [String: String]? {
        return nil
    }
    
    func execute() {

        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 60
        manager.request(path(), method: method(), parameters: params(), encoding: JSONEncoding.default, headers: headers()).responseJSON(completionHandler: { response in
            
            print(self.params() ?? "")
            print("\n------------------------------------------------------")
            print("------------------------------------------------------")
            print("REQUEST:")
            print("\(String(describing: response.request))")
            print("------------------------------------------------------")
            print("RESPONSE:")
            print("\(String(describing: response.response))")
            print("------------------------------------------------------")
            print("RESULT:")
            print("\(response.result)")
            print("------------------------------------------------------")
            print("JSON:\n\(String(describing: response.result.value))")
            print("------------------------------------------------------")
            print("------------------------------------------------------\n")

            if self.completionBlock != nil {
                
                if let responseValue = response.result.value {
                    let json = JSON(responseValue)
                    
                    if (json["error"] != JSON.null)
                    {
                        self.completionBlock!(nil,json["error"])
                    }else{
                        self.completionBlock!(json, nil)
                    }
                }else {
                    self.completionBlock!(nil, "Ocurrio un error , favor de intentar mas tarde.") //"\(response.result.error)")
                }
                
            }
            
        })
        
    }

}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
