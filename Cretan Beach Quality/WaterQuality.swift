//
//  WaterQuality.swift
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

extension WaterQuality {
    var regionName: String {
        switch perunit {
        case "ΧΑΝΙΩΝ":
            return "Chania"
        case "ΛΑΣΙΘΙΟΥ":
            return "Lasithi"
        case "ΡΕΘΥΜΝΟΥ":
            return "Rethymno"
        case "ΗΡΑΚΛΕΙΟΥ":
            return "Heraklion"
        case "Κρήτη", "Ν/Α":
            return "Crete"
        case nil:
            return "Crete"
        default:
            return "Crete"
        }
    }
}

