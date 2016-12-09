//
//  NetTypes.swift
//  Kitu
//
//  Created by Rui Caneira on 12/2/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import Foundation
import Genome
struct KInfo : BasicMappable {

    private(set) var placeID: String?
    private(set) var placeName: String?
    private(set) var placeAddress: String?
    private(set) var placeDescription: String?
    private(set) var placeDate: String?
    private(set) var placeRating: String = ""
    private(set) var placeLatitude: String = ""
    private(set) var placeLongitude: String = ""
    private(set) var placeImage: String = ""
    private(set) var placeWebsite: String = ""
    private(set) var placePhone: String = ""
    private(set) var placeRatingCount: String = ""
    mutating func sequence(map: Map) throws {
        
        try placeID <~ map["id"]
        try placeName <~ map["placeName"]
        try placeAddress <~ map["placeAddress"]
        try placeDescription <~ map["placeDescription"]
        try placeDate <~ map["placeDate"]
        try placeRating <~ map["placeRating"]
        try placeLatitude <~ map["placeLatitude"]
        try placeLongitude <~ map["placeLongitude"]
        try placeImage <~ map["placeImage"]
        try placeWebsite <~ map["placeWebsite"]
        try placePhone <~ map["placePhone"]
        try placeRatingCount <~ map["placeRatingCount"]
    }
}
struct EHResult : BasicMappable {
    private(set) var status: String = ""
    mutating func sequence(map: Map) throws {
        try status <~ map["msg"]
    }
}

