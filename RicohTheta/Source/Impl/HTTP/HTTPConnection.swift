//
//  HTTPConnection.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import Foundation

private enum Errors: Error {

    case invalidUrl
}

final public class HttpConnection: HttpConnectionProtocol {

    private(set) var session: URLSession
    private let queue = DispatchQueue(label: "com.ricoh.theta.connection.queue")

    public init(_ session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    public func createRequest(path: String, method: String) throws -> URLRequest {

        let urlString = "http://192.168.1.1" + path
        guard let url = URL(string: urlString) else {
            throw Errors.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json; charaset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    public func createInfoRequest() throws -> URLRequest {

        try self.createRequest(path: "/osc/info", method: "GET")
    }

    public func createExecuteRequest() throws -> URLRequest {

        try self.createRequest(path: "/osc/commands/execute", method: "POST")
    }

    public func createStatusRequest() throws -> URLRequest {

        try self.createRequest(path: "/osc/commands/status", method: "POST")
    }

    public func request<P: Codable, T: Codable>(
        using request: URLRequest,
        payload: P,
        _ completionHandler: @escaping (_ result: T?, _ error: Error?) -> Void) {

        self.queue.async {

            var request = request
            if request.httpMethod != "GET" {
                // When request httpMethod is GET, it does not allow httpBody in it
                request.httpBody = try? JSONEncoder().encode(payload)
            }

            let dataTaskRequest = self.session.dataTask(with: request) { (data, response: URLResponse?, error) in

                let urlResponse = response as? HTTPURLResponse

                if let error = error {

                    completionHandler(nil, error)
                    return
                } else if let data = data, urlResponse?.isResponseOK() ?? false {

                    do {

                        var object: T

                        if let dataObject = data as? T {

                            object = dataObject
                        } else {

                            object = try JSONDecoder().decode(T.self, from: data)
                        }

                        completionHandler(object, nil)

                    } catch {

                        completionHandler(nil, error)
                    }
                } else {

                    completionHandler(nil, RicohThetaError.cameraAPIError)
                }
            }

            dataTaskRequest.resume()
        }
    }

    public func download(
        using request: URLRequest,
        _ completionHandler: @escaping RicohThetaImageCompletion) {

        let dataTaskRequest = self.session.downloadTask(with: request) { (url, _, error) in

            if let error = error {

                completionHandler(nil, error)
                return
            }

            guard let url = url else {
                completionHandler(nil, RicohThetaError.cameraDownloadImageUrlNotExists)
                return
            }

            guard let data = try? Data(contentsOf: url) else {
                completionHandler(nil, RicohThetaError.cameraDownloadImageDataNotExists)
                return
            }

            guard let image = UIImage(data: data) else {
                completionHandler(nil, RicohThetaError.cameraDownloadImageNotExists)
                return
            }

            DispatchQueue.main.async {

                completionHandler(image, nil)
            }
        }

        dataTaskRequest.resume()
    }
}

extension HTTPURLResponse {

    func isResponseOK() -> Bool {

        return (200...299).contains(self.statusCode)
    }
}
