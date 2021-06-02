//
//  CommandPayload.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

// swiftlint:disable identifier_name

public struct CommandPayload: Codable {

    public enum Action: String {

        case startSession = "camera.startSession"
        case takePicture = "camera.takePicture"
        case getImage = "camera.getImage"
        case getLivePreview2Dot1 = "camera.getLivePreview"
        case getLivePreview2Dot0 = "camera._getLivePreview"
        case getOptions = "camera.getOptions"
        case setOptions = "camera.setOptions"
    }

    public let id: String?
    public let name: String?
    public let parameters: JSON?

    public init(using id: String? = nil) {

        self.id = id
        self.name = nil
        self.parameters = nil
    }

    public init(_ command: Action? = nil, with parameters: JSON? = nil) {

        self.id = nil
        self.name = command?.rawValue
        self.parameters = parameters
    }
}
