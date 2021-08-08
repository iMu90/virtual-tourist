//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 02/08/2021.
//

import Foundation


struct PhotosResponse: Codable {
    let stat: String
    let photos: Photos
    
}
struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
//    public let photo: [Photo]
}

struct Photo: Codable {
    public let id: String
    public let owner: String
    public let secret: String
    public let farm: Int
    public let title: String
    public let server: String
}
