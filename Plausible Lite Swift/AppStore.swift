//
//  AppStore.swift
//  Plausible Lite Swift
//
//  Created by Nicolas Pellerin on 2023-01-03.
//

import Foundation
import SwiftUI

struct Data: Codable {
    var apiKey: String = ""
    var siteId: String = ""
}

let initialData = Data(apiKey: "", siteId: "")

class AppStore: ObservableObject {
    @Published var plausibleData: Data = initialData
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension("plaulite.data")
    }
    
    static func delete(completion: @escaping (Result<Data, Error>)->Void) {
       DispatchQueue.global(qos: .background).async {
           do {
               let data = try JSONEncoder().encode(initialData)
               let outfile = try fileURL()
               try data.write(to: outfile)
               DispatchQueue.main.async {
                   completion(.success(initialData))
               }
           } catch {
               DispatchQueue.main.async {
                   completion(.failure(error))
               }
           }
       }
   }
    
    static func load(completion: @escaping (Result<Data, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(initialData))
                    }
                    
                    return
                }
                
                let pData = try JSONDecoder().decode(Data.self, from: file.availableData)
                
                DispatchQueue.main.async {
                    completion(.success(pData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    static func save(pData: Data, completion: @escaping (Result<Data, Error>)->Void) {
       DispatchQueue.global(qos: .background).async {
           do {
               let data = try JSONEncoder().encode(pData)
               let outfile = try fileURL()
               try data.write(to: outfile)
               DispatchQueue.main.async {
                   completion(.success(pData))
               }
           } catch {
               DispatchQueue.main.async {
                   completion(.failure(error))
               }
           }
       }
   }
}
