//
//  HttpStream.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

final class HttpStream: NSObject, HttpStreamProtocol {

    enum HttpStreamError: Error {
        case badResponse, parseImageProvider, parseCGImage
    }

    // Start and end markers for images in JPEG format
    let startMarker = Data([0xFF, 0xD8])
    let endMarker = Data([0xFF, 0xD9])
    let queue = DispatchQueue(label: "com.ricoh.theta.stream.queue")

    var buffer = Data()

    var request: URLRequest
    var task: URLSessionTask?

    var isLivePreviewing: Bool = false
    var imageCompletion: RicohThetaImageCompletion?

    deinit {

        self.stopLivePreview()
    }

    required init(request: URLRequest) {

        self.request = request
        super.init()
    }

    public func startLivePreview(for command: CommandPayload.Action, with parameter: JSON?) {

        if !self.isLivePreviewing {

            let payload = CommandPayload(command, with: parameter)
            self.request.httpBody = try? JSONEncoder().encode(payload)

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 5
            config.waitsForConnectivity = true
            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)

            self.task = session.dataTask(with: self.request)
            self.task?.resume()
            self.isLivePreviewing = true
        }
    }

    public func stopLivePreview() {

        self.task?.cancel()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data) {

        guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
            self.imageCompletion?(nil, HttpStreamError.badResponse)
            return
        }

        if data.range(of: self.startMarker) != nil {
            // started new frame
            self.buffer = Data() // clean up buffer
        }

        self.buffer.append(data)

        // frame has ended if not nil
        if data.range(of: self.endMarker) != nil {
            // finished frame
            self.parseFrame(self.buffer) { [weak self] image, error in
                guard let self = self else { return }
                self.imageCompletion?(image, error)
            }
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {

        session.invalidateAndCancel()
        self.isLivePreviewing = false
        self.imageCompletion?(nil, error)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        session.invalidateAndCancel()
        self.isLivePreviewing = false
        self.imageCompletion?(nil, error)
    }

    private func parseFrame(_ data: Data, _ completion: @escaping ((UIImage?, Error?) -> Void)) {

        self.queue.async {

            guard let imgProvider = CGDataProvider(data: data as CFData) else {
                completion(nil, HttpStreamError.parseImageProvider)
                return
            }

            guard let image = CGImage(
                    jpegDataProviderSource: imgProvider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent) else {
                completion(nil, HttpStreamError.parseCGImage)
                return
            }

            completion(UIImage(cgImage: image), nil)
        }
    }
}
