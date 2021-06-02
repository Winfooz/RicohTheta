//
//  RicohThetaCommanderProtocol.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

public protocol RicohThetaCommanderProtocol {

    init(using httpConnection: HttpConnectionProtocol, with sessionDTO: SessionDTO?)

    func livePreview(
        _ completionHandler: @escaping RicohThetaImageCompletion)

    func stopLivePreview()

    func takePicture(
        progressHandler: RicohThetaProgressCompletion?,
        completionHandler: @escaping RicohThetaImageCompletion)

    func getAvailableOptions(
        _ completionHandler: @escaping RicohThetaGetOptionCompletion)

    func setOption(
        _ option: OptionPayload.Option,
        with value: Any,
        _ completionHandler: @escaping RicohThetaSetOptionCompletion)
}
