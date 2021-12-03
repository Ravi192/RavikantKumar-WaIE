//
//  NASAAPODClient.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import Foundation
import CoreData

class NASAAPODClient {
    var session = URLSession.shared
    let apiKey : String = "wETSpWZCeCfayWYAgkSdbReWqUmQbBq0yq2TuI3g"
    
    class func sharedInstance() -> NASAAPODClient {
        struct Singleton {
            static var sharedInstance = NASAAPODClient()
        }
        return Singleton.sharedInstance
    }
    
    func taskForGETMethod1(parseJSON: Bool, completionHandlerForGET: @escaping (_ result: Any?, _ error: Error?, _ dataTas: Data) -> Void) -> URLSessionDataTask {
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=" + apiKey)!
        let request = URLRequest(url: url)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo), data!)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if parseJSON {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            } else {
                completionHandlerForGET(data as AnyObject?, nil, data)
            }
        })
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(parameters: [String: AnyObject], parseJSON: Bool, completionHandlerForGET: @escaping (_ result: Any?, _ error: Error?) -> Void) -> URLSessionDataTask {
        var params = parameters
        params.merge(dict: [URLKeys.APIKey: URLValues.NASAAPIKey as AnyObject])
        
        var url: URL = self.apodURLFromParameters(parameters: params)
        let request = URLRequest(url: url)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if parseJSON {
            } else {
                completionHandlerForGET(data as AnyObject?, nil)
            }
        })
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func apodURLFromParameters(parameters: [String:AnyObject]) -> URL {
        
        let components = NSURLComponents()
        components.scheme = NASAAPODClient.Constants.ApiScheme
        components.host = NASAAPODClient.Constants.ApiHost
        components.path = NASAAPODClient.Constants.ApiPath
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: Any?, _ error: NSError?, _ data: Data) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), data)
        }
        
        completionHandlerForConvertData(parsedResult, nil, data)
    }
}
