//
//  Constants.swift
//  Pixel-Map
//
//  Created by Amr on 6/25/19.
//  Copyright © 2019 Amr. All rights reserved.
//

import Foundation

let ApiKey = "10d170bfb76821da311b2f3666522576"

func FlickrUrl(forApiKey key:String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number:Int) -> String {
    
 return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(ApiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
   
}

