//
//  HttpConnectionProtocol.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import Foundation

public protocol HttpConnectionProtocol {

    func createInfoRequest() throws -> URLRequest
    func createRequest(path: String, method: String) throws -> URLRequest
    func createStatusRequest() throws -> URLRequest
    func createExecuteRequest() throws -> URLRequest
    func request<P: Codable, T: Codable>(
        using request: URLRequest,
        payload: P,
        _ completionHandler: @escaping (_ result: T?, _ error: Error?) -> Void)
    func download(
        using request: URLRequest,
        _ completionHandler: @escaping RicohThetaImageCompletion)
}
