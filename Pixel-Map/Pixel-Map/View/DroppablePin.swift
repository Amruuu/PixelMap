//
//  DroppablePin.swift
//  Pixel-Map
//
//  Created by Amr on 6/4/19.
//  Copyright © 2019 Amr. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation{
 dynamic var coordinate: CLLocationCoordinate2D//dynamic ..> able to be modified when we need to create MKAnnotation
    var identifier: String
    init(coordinate:CLLocationCoordinate2D,identifier:String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
