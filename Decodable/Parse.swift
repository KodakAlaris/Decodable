//
//  Parse.swift
//  Decodable
//
//  Created by Johannes Lund on 2015-08-13.
//  Copyright © 2015 anviking. All rights reserved.
//

import Foundation

func decodeArray<T: Decodable>(ignoreInvalidObjects: Bool = false)(json: AnyObject) throws -> [T] {
    
    guard let array = json as? [AnyObject] else {
        let info = DecodingError.Info(object: json)
        throw DecodingError.TypeMismatch(type: [T].self, info: info)
    }
    
    var newArray = [T]()
    for obj in array {
        do {
            try newArray.append(T.decode(obj))
        } catch let error {
            if ignoreInvalidObjects == false {
                throw error
            }
        }
    }
    
    return newArray
}

func parse<T>(json: AnyObject, path: [String], decode: (AnyObject throws -> T)) throws -> T {
    
    var object = json
    
    if let lastKey = path.last {
        var path = path
        path.removeLast()
        
        var currentDict = try NSDictionary.decode(json)
        var currentPath: [String] = []
        
        func objectForKey(dictionary: NSDictionary, key: String) throws -> AnyObject {
            guard let result = dictionary[key] else {
                let info = DecodingError.Info(object: dictionary, rootObject: json, path: currentPath)
                throw DecodingError.MissingKey(key: key, info: info)
            }
            return result
        }
        
        for key in path {
            currentDict = try NSDictionary.decode(objectForKey(currentDict, key: key))
            currentPath.append(key)
        }
        
        
        
        object = try objectForKey(currentDict, key: lastKey)
    }
    
    return try catchAndRethrow(json, path) { try decode(object) }
    
}
    
    


// MARK: - Helpers

func catchAndRethrow<T>(json: AnyObject?, _ path: [String]?, block: Void throws -> T) throws -> T {
    do {
        return try block()
    } catch var error as DecodingError {
        if var path = path where path.count > 0 {
            error.info.path = path
        }
        
        if let json = json {
            error.info.rootObject = json
        }
        throw error
    } catch let error {
        throw error
    }
}

func catchAndPrint<T>(block: Void throws -> T) -> T? {
    do {
        return try block()
    } catch {
        
    }
    return nil
}