//
//  Net.swift
//  Kitu
//
//  Created by Rui Caneira on 12/2/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//
import Foundation
import BrightFutures
class Net {
    class func requestServer(urlString: String, params: [String: AnyObject]) -> Future<[KInfo], NSError>
    {
        let promise = Promise<[KInfo], NSError>()
        Webservice.request(urlString, params: params, animated: true).onSuccess { (result: WebResult<KInfo>) -> Void in
            promise.success(result.array)
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func requestGetServer(urlString: String, params: [String: AnyObject]) -> Future<Bool, NSError>
    {
        let promise = Promise<Bool, NSError>()
        Webservice.request(urlString, params: params, animated: true).onSuccess { (result: WebResult<EHResult>) -> Void in
            if result.value?.status == "success" {
                promise.success(true)
            }else{
                let error = NSError(domain: result.value!.status, code: 1, userInfo: nil)
                promise.failure(error)
            }
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        return promise.future
    }
    class func getRealUrl(action: String!) -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var apiKey = ""
        apiKey = (userDefaults.objectForKey("apikey") as? String)!
        
        let urlString = EHNet.BASE_URL
            + "api-key=" + apiKey + "&"
            + action
        return urlString
    }
    class func uploadData(image: UIImage, params: [String: AnyObject]!) -> Future<Bool, NSError>
    {
        let promise = Promise<Bool, NSError>()
        let urlString = EHNet.BASE_URL
        let imageData = NSData(data: UIImageJPEGRepresentation(image, 1.0)!)
        Webservice.uploadImageData(urlString, imageData: imageData, params: params, animated: true).onSuccess { (result: WebResult<EHResult>) -> Void in
            if result.value?.status == "success" {
                promise.success(true)
            }else{
                let error = NSError(domain: result.value!.status, code: 1, userInfo: nil)
                promise.failure(error)
            }
            }.onFailure { (error) -> Void in
                print("Error: \(error)")
                promise.failure(error)
        }
        
        return promise.future
    }
    
}

