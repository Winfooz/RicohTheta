//
//  CommandDTO.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

// swiftlint:disable identifier_name

/// Command state
public enum CommandState: String, Codable {

    case done
    case inProgress
    case error
}

/// Command DTO
///
/// https://api.ricoh/docs/theta-web-api-v2/protocols/commands_execute/
public struct CommandDTO: Codable {

    let name: String?
    let state: CommandState?
    let id: String?
    let results: JSON?
    let error: JSON?
    let progress: JSON?
}
