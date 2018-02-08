//
//  JSONReader.swift
//  ALUtilse
//
//  Created by Aleksey Lobanov on 27.07.16.
//  Copyright © 2016 Aleksey Lobanov Lab. All rights reserved.
//

import Foundation
import ObjectMapper

public class JSONReader {

  public class func readFromJSON<T: Mappable>(_ filename: String) -> T? {
    return Mapper<T>().map(JSONString: JSONReader.readJSONString(filename)!)
  }
  
  public class func readFromJSON(_ filename: String, forClass: AnyClass = JSONReader.self) -> [String: AnyObject]? {
    do {
      let data = JSONReader.readJSONData(filename, forClass: forClass)

      guard let result = try JSONSerialization
        .jsonObject(with: data, options: []) as? [String: AnyObject] else {
          return nil
      }
    
      return result
    } catch {
      return nil
    }
  }

  public class func readJSONString(_ filename: String, forClass: AnyClass = JSONReader.self) -> String? {
    return String(data: readJSONData(filename, forClass: forClass), encoding: String.Encoding.utf8)
  }

  public class func readJSONData(_ filename: String, forClass: AnyClass = JSONReader.self) -> Data {
    return FileReader.readFileData(filename, fileExtension: "json")
  }

}
