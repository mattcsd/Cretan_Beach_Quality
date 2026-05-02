//
//  GovAPIRequest.swift
//  Cretan Beach Quality
//
//  Created by Admin on 2/5/26.
//

protocol GovAPIRequest : APIRequest {
    
}

extension GovAPIRequest {
    var baseUrl: String {"data.gov.gr"}
}
