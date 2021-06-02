//
//  RicohThetaProvider.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import Foundation

open class RicohThetaProvider {

    private var loggers: [RicohThetaLogger] = [DefaultRicohThetaLogger()]

    public weak var delegate: RicohThetaProviderDelegate?
    public private(set) var state: RicohThetaState = .notConnected {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.delegate?.thetaCamera(state: self.state)
            }
        }
    }

    public private(set) var deviceInfo: DeviceInfoDTO?

    private let httpConnection: HttpConnectionProtocol
    private let ricohThetaDeviceInfo: RicohThetaDeviceInfoProtocol
    private var commander: RicohThetaCommanderProtocol?

    public init(
        httpConnection: HttpConnectionProtocol = HttpConnection(),
        thetaCamera: RicohThetaDeviceInfoProtocol = RicohThetaDeviceInfo()) {

        self.httpConnection = httpConnection
        self.ricohThetaDeviceInfo = thetaCamera
    }

    /// Attach logger for debugging or logging
    /// - Parameter logger: logger that implement `RicohThetaLogger`
    /// - Returns: return self as discardable result
    @discardableResult
    public func attachLogger(_ logger: RicohThetaLogger) -> Self {

        self.loggers.append(logger)
        return self
    }

    /// Connect to theta camera
    ///
    /// By default the connection always will be 192.168.1.1, results will return using `delegate`
    public func connect() {

        self.state = .connecting
        self.ricohThetaDeviceInfo.getDeviceInfo(using: self.httpConnection) { [weak self] (commander, info, error) in

            if let error = error {

                self?.state = .notConnected
                self?.error(error: error)
            } else {

                let state: RicohThetaState = info != nil && commander != nil ? .idle : .notConnected
                self?.deviceInfo = info
                self?.state = state
                self?.commander = commander
            }
        }
    }

    /// Take picture while theta camera is idle
    ///
    /// Results will return using `delegate`
    public func takePicture() {

        switch self.state {

        case .notConnected:
            self.error(error: RicohThetaError.cameraNotConnected)
            return
        case .executing:
            self.error(error: RicohThetaError.cameraIsExecuting)
            return
        default:
            self.log("Camera is idle, start capture")
        }

        guard let apiCommander = self.commander else {
            self.error(error: RicohThetaError.cameraCommanderNotExists)
            return
        }

        self.state = .executing
        apiCommander.takePicture(progressHandler: { [weak self] progress in

            if let progress = progress {

                DispatchQueue.main.async {
                    self?.delegate?.thetaCamera(progress: progress)
                }
            }
        }, completionHandler: { [weak self] (image, error) in

            if let error = error {

                self?.error(error: error)
            } else if let image = image {

                DispatchQueue.main.async {
                    self?.delegate?.thetaCamera(image: image)
                }
            }

            self?.state = .idle
        })
    }

    public func livePreview() {

        self.commander?.livePreview({ [weak self] (image, error) in

            if let error = error {

                self?.error(error: error)
                self?.state = .idle
            } else if let image = image {

                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.thetaCamera(livePreview: image)
                }

                if self?.state != .livePreviewing && self?.state == .idle {

                    self?.state = .livePreviewing
                }
            }
        })
    }

    public func stopLivePreview() {

        self.commander?.stopLivePreview()

        if self.state == .livePreviewing {

            self.state = .idle
        }
    }

    public func getAvailableOptions() {

        self.commander?.getAvailableOptions({ [weak self] options, error in

            if let error = error {

                self?.error(error: error)
            } else if let options = options {

                DispatchQueue.main.async { [weak self] in

                    self?.delegate?.thetaCamera(optionsDTO: options)
                }
            }
        })
    }

    public func setOption(_ option: OptionPayload.Option, value: Any) {

        self.commander?.setOption(option, with: value, { [weak self] (option, value, error) in

            DispatchQueue.main.async { [weak self] in

                self?.delegate?.thetaCamera(option: option, value: value, error: error)
            }
        })
    }

    private func error(error: Error) {

        DispatchQueue.main.async { [weak self] in
            self?.log("Error: \(error.localizedDescription)")
            self?.delegate?.thetaCamera(error: error)
        }
    }

    private func log(_ text: String) {

        for logger in self.loggers {
            logger.log(text)
        }
    }
}
