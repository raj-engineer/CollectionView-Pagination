//
//  ApiHelper.swift
//  CollectionView-Pagination
//
//  Created by Rajesh on 30/11/18.
//  Copyright © 2018 Rajesh. All rights reserved.
//

import Foundation
import UIKit

typealias Parameters = [String: String]
class ApiHelper
{
    // Singleton Instance
    static let sharedApiHelper = ApiHelper()
    private init(){}
    
    //@escaping ((Data?) -> ()
    func createRequest (param :  [String : Any] , strURL : String , vc : UIViewController , type : String, completion: @escaping (Data)->()) {
        
        // Check Internet Connection
        if !(Reachability.isConnectedToNetwork()) {
            // No Internet connection
            Helper.sharedHelper.common_alert(vc: vc, title: "Message", message: Constants.Alerts.NoInternet.rawValue)
            return
        }
        
        // Show Activity Indicator
        // CustomActivityIndicator.sharedInstance.showActivityIndicator(uiView: vc.view)
        
        do {
            let jsonData =  try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) // the data will be converted to the string
            //let jsonData = try? JSONSerialization.data(withJSONObject: postString)
            print("\n\(type):  URL : \(strURL)")
            print("Request json ",jsonString ?? "defaultvalue")
            let url = URL(string: strURL)
            var request = URLRequest(url: url!)
            // request.httpMethod = "POST"
            //request.httpBody = jsonData
            // callApi(request: request, vc: vc, type: type)
            
            // 3
            let encodedURLRequest = request.encode(with: param as! Parameters)
            
            let task = URLSession.shared.dataTask(with: encodedURLRequest) { data, response, error in
                guard let data = data, error == nil else {
                    
                    DispatchQueue.main.async {
                        
                        if let msg = error?.localizedDescription{
                            print("error is ",error?.localizedDescription ?? "Nothing")
                            //  CustomActivityIndicator.sharedInstance.hideActivityIndicator(uiView: vc.view)
                            Helper.sharedHelper.common_alert(vc: vc, title: "Message", message: msg)
                        }
                    }
                    return
                }
                
                let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("Get Response  ",response)
                DispatchQueue.main.async {
                    
                    //  Passing the data from closure to the calling method
                    
                    completion(data)
                    // completion(data)
                }
            }
            
            task.resume()
            
            
            
            
        }
        catch let myJSONError {
            print(myJSONError)
        }
        
}
}


extension URLRequest {
    func encode(with parameters: Parameters?) -> URLRequest {
        guard let parameters = parameters else {
            return self
        }
        
        var encodedURLRequest = self
        
        if let url = self.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            var newUrlComponents = urlComponents
            let queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            newUrlComponents.queryItems = queryItems
            encodedURLRequest.url = newUrlComponents.url
            return encodedURLRequest
        } else {
            return self
        }
    }
}
