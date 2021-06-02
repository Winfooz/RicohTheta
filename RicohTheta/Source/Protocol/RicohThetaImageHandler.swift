//
//  RicohThetaImageHandler.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

protocol RicohThetaImageHandler {

    func handleImage(
        _ commandDTO: CommandDTO?,
        _ progressValue: CGFloat,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion)

    func downloadImage(
        fileUrl: String,
        _ progressValue: CGFloat,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion)

    func downloadImage(
        fileUri: String,
        _ progressValue: CGFloat,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion)
}

extension RicohThetaImageHandler {

    private static var timeInterval: TimeInterval {
        0.5
    }

    private static var defaultIncrementalProgress: CGFloat {
        0.0375
    }

    fileprivate func handleResponse(
        _ commandDTO: CommandDTO?,
        _ progressValue: CGFloat = 0.0,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion,
        _ commandResponse: CommandDTO) {

        var progressValue: CGFloat = progressValue

        if let result = commandResponse.results, commandResponse.state == .done {

            if let file = result.objectValue?["fileUrl"]?.stringValue {
                // v2.1
                self.downloadImage(
                    fileUrl: file,
                    progressValue,
                    httpConnection,
                    progressHandler,
                    completionHandler)
            } else if let file = result.objectValue?["fileUri"]?.stringValue {
                // v2.0
                self.downloadImage(
                    fileUri: file,
                    progressValue,
                    httpConnection,
                    progressHandler,
                    completionHandler)
            } else {

                completionHandler(nil, RicohThetaError.cameraFileUrlNotExists)
            }
        } else if let progress = commandResponse.progress {

            let completion: CGFloat = CGFloat(progress.objectValue?["completion"]?.doubleValue ?? 0.0)

            if completion == 0 {

                progressValue += Self.defaultIncrementalProgress
            } else if completion >= progressValue {

                progressValue = completion
            }

            progressHandler?(progressValue)
            // keep call my self until error or result is done.
            self.handleImage(commandDTO, progressValue, httpConnection, progressHandler, completionHandler)
        }
    }

    func handleImage(
        _ commandDTO: CommandDTO?,
        _ progressValue: CGFloat = 0.0,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion) {

        // after taking a picture, wait a little bit, then continue
        Thread.sleep(forTimeInterval: Self.timeInterval) // 0.5 sec

        guard let commandId = commandDTO?.id else {
            completionHandler(nil, RicohThetaError.cameraCommandIdNotExists)
            return
        }

        do {

            let request = try httpConnection.createStatusRequest()
            let payload = CommandPayload(using: commandId)
            httpConnection.request(using: request, payload: payload) { (commandResponse: CommandDTO?, error) in

                if let error = error {
                    completionHandler(nil, error)
                    return
                }

                guard let commandResponse = commandResponse else {
                    completionHandler(nil, RicohThetaError.cameraCommandNotExists)
                    return
                }

                self.handleResponse(
                    commandDTO,
                    progressValue,
                    httpConnection,
                    progressHandler,
                    completionHandler,
                    commandResponse)
            }
        } catch {

            completionHandler(nil, error)
        }
    }

    func downloadImage(
        fileUrl: String,
        _ progressValue: CGFloat,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion) {

        guard let url = URL(string: fileUrl) else {
            completionHandler(nil, RicohThetaError.cameraInvalidFileUrl)
            return
        }

        var progressValue = progressValue
        let timer = Timer.scheduledTimer(withTimeInterval: Self.timeInterval, repeats: true) { _ in
            progressValue += Self.defaultIncrementalProgress
            progressHandler?(progressValue)
        }

        timer.fire()
        let request = URLRequest(url: url)
        httpConnection.download(using: request) { image, error in

            timer.invalidate()
            image != nil ? progressHandler?(1.0) : nil
            completionHandler(image, error)
        }
    }

    func downloadImage(
        fileUri: String,
        _ progressValue: CGFloat,
        _ httpConnection: HttpConnectionProtocol,
        _ progressHandler: RicohThetaProgressCompletion?,
        _ completionHandler: @escaping RicohThetaImageCompletion) {

        do {

            let request = try httpConnection.createExecuteRequest()
            let payload = CommandPayload(.getImage, with: try JSON(["fileUri": fileUri]))

            var progressValue = progressValue
            let timer = Timer.scheduledTimer(withTimeInterval: Self.timeInterval, repeats: true) { _ in
                progressValue += Self.defaultIncrementalProgress
                progressHandler?(progressValue)
            }

            httpConnection.request(using: request, payload: payload) { (data: Data?, error) in

                timer.invalidate()
                if let data = data, let image = UIImage(data: data) {

                    progressHandler?(1.0)
                    completionHandler(image, nil)
                } else {

                    completionHandler(nil, error)
                }
            }
        } catch {

            completionHandler(nil, error)
        }
    }
}
