//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Bill Clark on 7/10/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation

struct FlickrConstants{
    
        static let flickrBaseAPI = "https://www.flickr.com/services/rest/"
        static let fMethod = "?method=flickr.photos.search"
        static let jsonHeader = "application/json"
        static let acceptHeader = "Accept"
        static let contentType = "Content-Type"
        static let apiKey = "&api_key=393010fd62914ab3e3c09de34b7701d3"
        static let lat = "&lat="
        static let long = "&lon="
        static let extras = "&extras=url_m"
        static let perPage = "&per_page=21"
        static let page = "&page="
        static let format = "&format=json"
        static let jsoncallback = "&nojsoncallback=1"
    
}
