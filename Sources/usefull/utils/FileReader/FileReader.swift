//
//  FileReader.swift
//  ALUtilse
//
//  Created by Aleksey Lobanov on 27.07.16.
//  Copyright © 2016 Aleksey Lobanov Lab. All rights reserved.
//

import Foundation

public class FileReader {
  public class func readFileData(_ filename: String, fileExtension: String, forClass: AnyClass = FileReader.self) -> Data {
    if let path = Bundle(for: forClass).path(forResource: filename, ofType: fileExtension) {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path),
                              options: NSData.ReadingOptions.mappedIfSafe)
        return data
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    } else {
      print("Could not find file: \(filename).\(fileExtension)")
    }
    return Data()
  }

  public class func readFileString(_ filename: String, fileExtension: String, forClass: AnyClass = FileReader.self) -> String {
    return String(data: readFileData(filename, fileExtension: fileExtension),
                  encoding: String.Encoding.utf8) ?? ""
  }
}
