//
//  Art.swift
//  MapSwiftIOS
//
//  Created by WSR on 24/06/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import Foundation
import RealmSwift

class Art: Object, Decodable {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var subTitle = ""
    @objc dynamic var image = ""
    @objc dynamic var lat = ""
    @objc dynamic var long = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
