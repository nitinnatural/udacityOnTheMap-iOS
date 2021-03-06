//
//  UdacityApi.swift
//  On the Map
//
//  Created by Nitin Anand on 04/07/20.
//  Copyright © 2020 NI3X. All rights reserved.
//

import Foundation
class UdacityApi {
    enum Endpoints : Any {
        case getUsers(Int)
        case postLocation
        case getSession
        var url:URL {
            return URL(string: self.stringValue)!
        }
        var stringValue: String {
            switch self {
            case .getUsers(let limit):
                return "https://onthemap-api.udacity.com/v1/StudentLocation?limit=\(limit)&order=-updatedAt"
            case .postLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .getSession:
                return "https://onthemap-api.udacity.com/v1/session"
            default:
                print("")
            }
        }
    }
    
    
    
    class func postUserLocation(userLocationRequest:PostUserLocationRequest, completionHandler: @escaping(String?, Error?)->Void){
        var request = URLRequest(url: Endpoints.postLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(userLocationRequest)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            completionHandler("suceess", nil)
            print(String(data: data, encoding: .utf8)!)
        }.resume()
    }
    
    
    class func getUsers(completionHandler: @escaping (UserResponse?, Error?)->Void) {
        let request = URLRequest(url: Endpoints.getUsers(100).url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let results = try! decoder.decode(UserResponse.self, from: data)
                completionHandler(results, nil)
            } catch {
                completionHandler(nil, error)
            }
        }.resume()
    }
    
    class func getSession(_ username:String, _ password:String, completionHandler: @escaping (String?, String?)->Void){
        let post = UdacityUserRequest(udacity:UserSession(username:username, password:password))
        var request = URLRequest(url: Endpoints.getSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(post)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, "something went wrong")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            do {
                let json = try JSONSerialization.jsonObject(with: newData, options: []) as! [String:Any]
                print(json)
                
                if let account = json["account"] {
                    let key = (account as! [String:Any])["key"] as! String
                    completionHandler(key, nil)
                    return
                }
                
                if let error = json["error"] {
                    completionHandler(nil, error as! String)
                }
                
                
            } catch {
                completionHandler(nil, error.localizedDescription)
            }
            
        }.resume()
    }
    
    
    
}
