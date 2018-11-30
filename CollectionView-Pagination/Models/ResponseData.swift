//
//  ResponseData.swift
//  CollectionView-Pagination
//
//  Created by Rajesh on 30/11/18.
//  Copyright © 2018 Rajesh. All rights reserved.
//

import Foundation

struct ResponseData : Codable{
    let items :[Items]?
    let has_more :Bool?
    let quota_max :Int?
    let quota_remaining:Int?
    let page:Int?
    let total:Int?
}

struct Items : Codable{
    let display_name: String?
    let profile_image: String?
}
