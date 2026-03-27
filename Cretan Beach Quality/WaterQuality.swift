//
//  WaterQuality.swift
//  Cretan Beach Quality
//
//  Created by Admin on 24/3/26.
//


//
//  WaterQuaity.swift
//  Cretan Beach Quality
//
//  Created by Admin on 23/3/26.
//

import Foundation

// optionals giati kapoia (mporei na) einai nil
struct WaterQuality: Codable{
    let perunit: String?
    let coast: String?
    let intenterococci: String?
    let ecoli: String?
    let sampleTimestamp: String?
    
    
    enum CodingKeys: String, CodingKey {
        case perunit
        case coast
        case intenterococci
        case ecoli
        case sampleTimestamp = "sample_timestamp"
    }
}


