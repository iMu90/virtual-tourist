//
//  FlickerApi.swift
//  Virtual Tourist
//
//  Created by Muteb Alolayan on 29/07/2021.
//

import Foundation


class FlickerApi {
    let API_KEY: String = "API_KEY"
    let API_SECRET: String = "SECRET"
    let NUMBER_OF_IMAGES_PER_PAGE: Int = 10
    let API_METHOD: String = "flickr.photos.getRecent"
    
    let decoder = JSONDecoder()
        
//    init() {
//        END_POINT_URL = "https://www.flickr.com/services/rest/?method=\(API_METHOD)&api_key=\(API_KEY)&per_page=\(NUMBER_OF_IMAGES_PER_PAGE)&page=1&format=json&nojsoncallback=1"
//    }
    
    func getImages(lat: String, lang: String) {
        let url: String = "https://www.flickr.com/services/rest/?method=\(API_METHOD)&api_key=\(API_KEY)&per_page=\(NUMBER_OF_IMAGES_PER_PAGE)&page=1&format=json&nojsoncallback=1"
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error")
            }
            guard let data = data else {
                return
            }
            
//            let range = 5..<data.count
//            let newData = data.subdata(in: range)
//            print("new Data: \(newData)")
            do {
                let responseObject = try self.decoder.decode(Photos.self, from: data)
                print("data: \(responseObject)")

            } catch {
                print("error \(error)")
            }
        }
        
        
        
        task.resume()
    }
}
