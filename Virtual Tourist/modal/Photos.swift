//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 02/08/2021.
//

import Foundation


class Photos: Decodable {
    public let photo: [Photo]
    
}
class Photo: Codable {
    public let id: String
    public let owner: String
    public let secret: String
    public let farm: String
    public let title: String
}
