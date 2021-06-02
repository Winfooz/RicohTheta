//
//  RicohThetaDeviceInfo.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import Foundation

public final class RicohThetaDeviceInfo: RicohThetaDeviceInfoProtocol {

    public init() {}

    public func getDeviceInfo(
        using httpConnection: HttpConnectionProtocol,
        _ completionHandler: @escaping RicohThetaDeviceInfoCompletion) {

        let group = DispatchGroup()

        var info: DeviceInfoDTO?
        var session: SessionDTO?
        var error: Error?

        do {

            group.enter()
            try self.getInfo(using: httpConnection) { (deviceInfoDTO: DeviceInfoDTO?, deviceError) in

                info = deviceInfoDTO
                error = deviceError
                group.leave()
            }

            group.enter()
            try self.getSession(using: httpConnection) { (sessionDTO: SessionDTO?, sessionError: Error?) in

                session = sessionDTO
                error = sessionError
                group.leave()
            }

            group.notify(queue: DispatchQueue(label: "com.ricoh.theta.device.info.queue")) {

                let commander = self.getCommander(httpConnection, info, session)
                completionHandler(commander, info, error)
            }

        } catch {

            completionHandler(nil, nil, error)
        }
    }

    private func getInfo(
        using httpConnection: HttpConnectionProtocol,
        _ completionHandler: @escaping (DeviceInfoDTO?, Error?) -> Void) throws {

        let request = try httpConnection.createInfoRequest()
        let payload = CommandPayload()

        httpConnection.request(using: request, payload: payload) { (info: DeviceInfoDTO?, error) in
            completionHandler(info, error)
        }

    }

    private func getSession(
        using httpConnection: HttpConnectionProtocol,
        _ completionHandler: @escaping (SessionDTO?, Error?) -> Void) throws {

        let request = try httpConnection.createExecuteRequest()
        let payload = CommandPayload(.startSession)

        httpConnection.request(using: request, payload: payload) { (commandDTO: CommandDTO?, error: Error?) in

            guard let results = commandDTO?.results,
                  let sessionId = results.objectValue?["sessionId"]?.stringValue,
                  let timeout = results.objectValue?["timeout"]?.doubleValue else {
                completionHandler(nil, error)
                return
            }

            let session = SessionDTO(sessionId: sessionId, timeout: Int(timeout))
            completionHandler(session, nil)
        }
    }

    private func getCommander(
        _ httpConnection: HttpConnectionProtocol,
        _ deviceInfo: DeviceInfoDTO?,
        _ session: SessionDTO?) -> RicohThetaCommanderProtocol? {

        guard let deviceInfoApiLevel = deviceInfo?.apiLevel else {
            return nil
        }

        let isTwoDotOne = deviceInfoApiLevel.contains(RicohThetaAPIVersion.twoDotOne.apiLevel)
        let isTwoDotZero = deviceInfoApiLevel.contains(RicohThetaAPIVersion.twoDotZero.apiLevel)

        if session != nil, !isTwoDotOne {

            return RicohThetaCommander2Dot0(using: httpConnection, with: session)
        } else if isTwoDotOne, session == nil {

            return RicohThetaCommander2Dot1(using: httpConnection, with: nil)
        } else if isTwoDotZero, session != nil {

            return RicohThetaCommander2Dot0(using: httpConnection, with: session)
        }

        return nil
    }
}
