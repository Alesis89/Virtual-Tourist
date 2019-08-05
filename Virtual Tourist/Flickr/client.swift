//
//  client.swift
//  Virtual Tourist
//
//  Created by Bill Clark on 7/10/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation
import UIKit

let session = URLSession.shared
let mainDelegate = UIApplication.shared.delegate as! AppDelegate

func getFlickrPhotosForPin(inLat: Double, inLon: Double, completion: @escaping (Bool)->()){
    
//    https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=393010fd62914ab3e3c09de34b7701d3&text=&lat=39.0997&lon=94.5786&extras=url_m&per_page=&format=json&nojsoncallback=1
    
    //Get current page number
    let pageNumber = mainDelegate.page
    
    let flickrURL = "\(FlickrConstants.flickrBaseAPI)\(FlickrConstants.fMethod)\(FlickrConstants.apiKey)\(FlickrConstants.lat)" + "\(inLat)" + "\(FlickrConstants.long)" + "\(inLon)" + "\(FlickrConstants.extras)\(FlickrConstants.perPage)\(FlickrConstants.page)" + "\(pageNumber)" + "\(FlickrConstants.format)\(FlickrConstants.jsoncallback)"
    
    let request = URLRequest(url: URL(string: flickrURL)!)
    
    
    let task = session.dataTask(with: request) { data, response, error in
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        let parsedResult: AnyObject!
        
        pinImages = []
        
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as AnyObject
            print(parsedResult!)
            
            if let photosDictionary = parsedResult["photos"] as? [String:AnyObject],
                let photoArray = photosDictionary["photo"] as? [[String:AnyObject]]{
                
               let maxPages = photosDictionary["pages"] as? Int
                mainDelegate.maxPages = maxPages!
                
                if maxPages == 0{
                    completion(true)
                }
                
                for dictionary in photoArray{
                    if let imageURLString = dictionary["url_m"] as? String{
                        pinImages.append(PinImage(pinImage: imageURLString))
//                        let imageURL = URL(string: imageURLString)
//                        if let imageData = try? Data(contentsOf: imageURL!) {
////                            pinImages.append(PinImage(pinImage: UIImage(data: imageData)!))
//                            pinImages.append(PinImage(pinImage: imageURLString))
                        //}
                    }
                }
            }
            completion(true)
        }catch{
            print("Could not parse JSON data.")
            completion(false)
            return
        }
    }
    task.resume()
}


