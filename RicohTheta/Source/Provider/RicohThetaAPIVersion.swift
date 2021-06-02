//
//  RicohThetaAPIVersion.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

/// Ricoh theta api version
///
///    Supported API version
///    (1: v2.0, 2: v2.1)
public enum RicohThetaAPIVersion {

    case twoDotZero
    case twoDotOne

    var apiLevel: Int {
        switch self {
        case .twoDotZero:
            return 1
        case .twoDotOne:
            return 2
        }
    }
}
