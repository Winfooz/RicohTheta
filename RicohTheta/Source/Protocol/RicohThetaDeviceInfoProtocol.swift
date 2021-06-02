//
//  RicohThetaDeviceInfoProtocol.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

public protocol RicohThetaDeviceInfoProtocol {

    func getDeviceInfo(
        using httpConnection: HttpConnectionProtocol,
        _ completionHandler: @escaping RicohThetaDeviceInfoCompletion)
}
