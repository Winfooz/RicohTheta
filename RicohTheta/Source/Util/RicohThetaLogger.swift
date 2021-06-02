//
//  RicohThetaLogger.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import Foundation

public protocol RicohThetaLogger: AnyObject {

    func log(_ text: String)
}

final class DefaultRicohThetaLogger: RicohThetaLogger {

    public func log(_ text: String) {

        DispatchQueue.main.async {
            #if DEBUG
            print("DefaultRicohThetaLogger: ", text)
            #endif
        }
    }
}
