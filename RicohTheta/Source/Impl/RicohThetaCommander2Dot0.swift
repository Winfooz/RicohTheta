//
//  RicohThetaCommander2Dot0.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

public final class RicohThetaCommander2Dot0: RicohThetaCommanderProtocol,
                                             RicohThetaImageHandler {
    private var session: SessionDTO?
    private var stream: HttpStream?
    private let httpConnection: HttpConnectionProtocol

    deinit {

        self.stream?.stopLivePreview()
    }

    public init(using httpConnection: HttpConnectionProtocol, with sessionDTO: SessionDTO?) {

        self.httpConnection = httpConnection
        self.session = sessionDTO
    }

    public func takePicture(
        progressHandler: RicohThetaProgressCompletion?,
        completionHandler: @escaping RicohThetaImageCompletion) {

        guard let session = self.session else {
            completionHandler(nil, RicohThetaError.cameraSessionNotExists)
            return
        }

        do {
            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(.takePicture, with: try JSON(["sessionId": session.sessionId]))

            self.httpConnection.request(
                using: request,
                payload: commandPayload) { [unowned self] (commandDTO: CommandDTO?, error: Error?) in

                if let error = error {
                    return completionHandler(nil, error)
                }

                self.handleImage(
                    commandDTO,
                    0.0,
                    self.httpConnection,
                    progressHandler,
                    completionHandler)
            }
        } catch {

            completionHandler(nil, error)
        }
    }

    public func livePreview(
        _ completionHandler: @escaping RicohThetaImageCompletion) {

        guard let session = self.session else {
            completionHandler(nil, RicohThetaError.cameraSessionNotExists)
            return
        }

        do {

            let request = try self.httpConnection.createExecuteRequest()
            self.stream = HttpStream(request: request)
            self.stream?.imageCompletion = { image, error in
                completionHandler(image, error)
            }

            self.stream?.startLivePreview(
                for: .getLivePreview2Dot0,
                with: try JSON(["sessionId": session.sessionId]))
        } catch {

            completionHandler(nil, error)
        }
    }

    public func stopLivePreview() {

        self.stream?.stopLivePreview()
    }

    public func getAvailableOptions(
        _ completionHandler: @escaping RicohThetaGetOptionCompletion) {

        guard let session = self.session else {
            completionHandler(nil, RicohThetaError.cameraSessionNotExists)
            return
        }

        do {

            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(
                .getOptions,
                with: try OptionPayload.getSupportedOptions(sessionId: session.sessionId))

            self.httpConnection.request(
                using: request,
                payload: commandPayload) { (commandDTO: CommandDTO?, error) in
                guard error == nil else { return completionHandler(nil, error) }
                guard let result = commandDTO?.results else {
                    return completionHandler(nil, RicohThetaError.cameraOptionsNotAvailable)
                }

                let optionDTO = OptionDTO(json: result)
                completionHandler(optionDTO, nil)
            }

        } catch {

            completionHandler(nil, error)
        }
    }

    public func setOption(
        _ option: OptionPayload.Option,
        with value: Any,
        _ completionHandler: @escaping RicohThetaSetOptionCompletion) {

        guard let session = self.session else {
            completionHandler(option, value, RicohThetaError.cameraSessionNotExists)
            return
        }

        do {

            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(
                .setOptions,
                with: try OptionPayload(sessionId: session.sessionId, option: option, value: value).json())

            self.httpConnection.request(
                using: request,
                payload: commandPayload) { (commandDTO: CommandDTO?, error: Error?) in
                guard error == nil && commandDTO != nil else {
                    return completionHandler(option, value, error)
                }

                completionHandler(option, value, nil)
            }

        } catch {

            completionHandler(option, value, error)
        }
    }
}
