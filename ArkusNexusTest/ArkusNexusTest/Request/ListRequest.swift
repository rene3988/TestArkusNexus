//
//  ListRequest.swift
//  ArkusNexusTest
//
//  Created by Rene Cabañas Lopez on 11/05/20.
//  Copyright © 2020 Rene Cabañas Lopez. All rights reserved.

import UIKit
import Alamofire

class ListRequest: BaseRequest {
    
    override init() {
        
    }
    
    override func path() -> String {
        return "\(apiEndpointURL)5bf3ce193100008900619966"
    }
    
    override func method() -> HTTPMethod {
        return .get
    }
    
    override func headers() -> [String : String]? {
        let headers = ["Content-Type": "application/json"]
        return headers
    }
    
    override func params() -> [String : Any]? {
        var _: [String: Any] = [:]
        return nil
    }

}
