//
//  FlickerApi.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 29/07/2021.
//

import Foundation
import UIKit

class FlickerApi {
    let API_KEY: String = "9679fec065a90d05de2a8b9631248555"
    let API_SECRET: String = "502b01bbcf52a44e"
    let NUMBER_OF_IMAGES_PER_PAGE: Int = 10
    let API_METHOD: String = "flickr.photos.search"
    let decoder = JSONDecoder()
    
    func getImages(location: GeoLocation, pageNumber: Int, completion: @escaping (Bool, PhotosResponse?, Error?) ->()) {
        let lat: String = location.latitude!
        let long: String = location.longitude!
        let url: String = "https://www.flickr.com/services/rest/?method=\(API_METHOD)&api_key=\(API_KEY)&per_page=\(NUMBER_OF_IMAGES_PER_PAGE)&page=\(pageNumber)&lat=\(lat)&lon=\(long)&format=json&nojsoncallback=1"
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(false, nil, error)
                return
            }
            guard let data = data else {
                completion(false, nil, nil)
                return
            }
            
            do {
                let responseObject = try self.decoder.decode(PhotosResponse.self, from: data)
                completion(true, responseObject, nil)
                return

            } catch {
                completion(false, nil, error)
            }
        }
        task.resume()
    }
    
    
    func loadData(location:GeoLocation, photos:[Photo]) -> GeoLocation {
        
        var imgUrl: String
        for photo in photos {
            imgUrl = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_w.jpg"
            self.downloadImg(url: imgUrl) { data, error in
                if error == nil {
//                    print("ddd: \(String(describing: data?.count))")
//                    let temp = Images()
//                    temp.data = data
//                    temp.name = photo.title
//                    temp.url = imgUrl
//                    location.images?.adding(temp)
                }
            }
        }
        
        return location
    }
    
    func downloadImg(url: String, completion: @escaping (Data?, Error?) -> Void) {
        if let imgURL = URL(string: url) {
            let task = URLSession.shared.dataTask(with: imgURL) { data, response, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                if let data = data {
                    completion(data, nil)
                    return
                }
                
            }
            task.resume()
        }
        
    }
}
