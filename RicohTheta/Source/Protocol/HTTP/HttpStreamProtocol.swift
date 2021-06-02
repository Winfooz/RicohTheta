//
//  HttpStreamProtocol.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

public protocol HttpStreamProtocol: URLSessionDataDelegate {

    init(request: URLRequest)

    func startLivePreview(for command: CommandPayload.Action, with parameter: JSON?)
    func stopLivePreview()
}
