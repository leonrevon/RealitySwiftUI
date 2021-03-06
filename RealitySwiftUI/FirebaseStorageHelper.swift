//
//  FirebaseStorageHelper.swift
//  RealityUIKit
//
//  Created by Leon Teng on 16.06.22.
//

import Foundation
import FirebaseStorage
import Firebase

class FirebaseStorageHelper {
    static private let cloudStorage = Storage.storage()
    
    class func asyncDownloadToFilesystem(relativePath: String, handler: @escaping (_ fileUrl: URL) -> Void) {
        
        //Create local filesystem URL
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = docsUrl.appendingPathComponent(relativePath)
        
        //Check if asset is already in the filesystem
        //If it is, load the asset and return
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            handler(fileUrl)
            return
        }
        
        //Create a reference to the asset
        let storageRef = cloudStorage.reference(withPath: relativePath)
        
        //Download to the local filesystem
        storageRef.write(toFile: fileUrl) { url, error in
            guard let localUrl = url else {
                print("Firebase storage: Error downloading file with relativePath with \(relativePath)")
                return
            }            
            handler(localUrl)
            
        }.resume()
    }
    
}
