//
//  RicohThetaTypealias.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

public typealias RicohThetaProgressCompletion = (_ progress: CGFloat?) -> Void

public typealias RicohThetaImageCompletion = (
    _ image: UIImage?,
    _ error: Error?) -> Void

public typealias RicohThetaGetOptionCompletion = (
    _ optionDTO: OptionDTO?,
    _ error: Error?) -> Void

public typealias RicohThetaSetOptionCompletion = (
    _ option: OptionPayload.Option,
    _ value: Any,
    _ error: Error?) -> Void

public typealias RicohThetaDeviceInfoCompletion = (
    _ commander: RicohThetaCommanderProtocol?,
    _ info: DeviceInfoDTO?,
    _ error: Error?) -> Void
