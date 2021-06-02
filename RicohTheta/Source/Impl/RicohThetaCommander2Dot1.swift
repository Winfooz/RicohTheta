//
//  RicohThetaCommander2Dot1.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

public final class RicohThetaCommander2Dot1: RicohThetaCommanderProtocol,
                                             RicohThetaImageHandler {

    private let httpConnection: HttpConnectionProtocol
    private var stream: HttpStream?

    deinit {

        self.stream?.stopLivePreview()
    }

    public init(using httpConnection: HttpConnectionProtocol, with sessionDTO: SessionDTO?) {

        self.httpConnection = httpConnection
    }

    public func takePicture(
        progressHandler: RicohThetaProgressCompletion?,
        completionHandler: @escaping RicohThetaImageCompletion) {

        do {
            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(.takePicture)

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

        do {

            let request = try self.httpConnection.createExecuteRequest()
            self.stream = HttpStream(request: request)
            self.stream?.imageCompletion = { image, error in
                completionHandler(image, error)
            }

            self.stream?.startLivePreview(for: .getLivePreview2Dot1, with: nil)
        } catch {

            completionHandler(nil, error)
        }
    }

    public func stopLivePreview() {

        self.stream?.stopLivePreview()
    }

    public func getAvailableOptions(
        _ completionHandler: @escaping RicohThetaGetOptionCompletion) {

        do {

            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(.getOptions, with: try OptionPayload.getSupportedOptions())

            self.httpConnection.request(
                using: request,
                payload: commandPayload) { (commandDTO: CommandDTO?, error) in
                guard error == nil else { return completionHandler(nil, error) }
                guard let result = commandDTO?.results else {
                    return completionHandler(nil, RicohThetaError.cameraOptionsNotAvailable)
                }

                let optionDTO = OptionDTO(json: result)
                completionHandler(optionDTO, error)
            }

        } catch {

            completionHandler(nil, error)
        }
    }

    public func setOption(
        _ option: OptionPayload.Option,
        with value: Any,
        _ completionHandler: @escaping RicohThetaSetOptionCompletion) {

        do {

            let request = try self.httpConnection.createExecuteRequest()
            let commandPayload = CommandPayload(
                .setOptions,
                with: try OptionPayload(option: option, value: value).json())

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
