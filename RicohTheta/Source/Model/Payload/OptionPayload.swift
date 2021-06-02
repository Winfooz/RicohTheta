//
//  OptionPayload.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

/// Option payload
///
/// https://api.ricoh/docs/theta-web-api-v2.1/options/index/
public struct OptionPayload: Codable {

    private static var defaultOptions: [String] = [
        Option.iso.rawValue,
        Option.iso.support,
        Option.whiteBalance.rawValue,
        Option.whiteBalance.support,
        Option.filter.rawValue,
        Option.filter.support]

    /// Check current options value and return supported options and values ranges
    /// - Parameters:
    ///   - sessionId: sessionId to support API version 2.0
    ///   - options: options to check if they are supported and their current values
    /// - Throws: Will throw an error if passed data is not JSON value representation
    /// - Returns: Will return JSON object
    static func getSupportedOptions(sessionId: String? = nil, for options: [String] = defaultOptions) throws -> JSON {

        let optionNames = "optionNames"

        if let sessionId = sessionId {

            return try JSON(["sessionId": sessionId, optionNames: options])
        } else {

            return try JSON([optionNames: options])
        }
    }

    /// Option
    ///
    /// - iso: https://api.ricoh/docs/theta-web-api-v2.1/options/iso/
    /// - whiteBalance: https://api.ricoh/docs/theta-web-api-v2.1/options/white_balance/
    /// - filter: https://api.ricoh/docs/theta-web-api-v2.1/options/_filter/
    /// - colorTemperature: https://api.ricoh/docs/theta-web-api-v2.1/options/_color_temperature/
    public enum Option: String {

        case iso = "iso"
        case whiteBalance = "whiteBalance"
        case filter = "_filter"
        case colorTemperature = "_colorTemperature"

        var support: String {

            self.rawValue + "Support"
        }
    }

    public init(sessionId: String? = nil, option: OptionPayload.Option, value: Any) throws {

        self.sessionId = sessionId
        self.options = try JSON([option.rawValue: value])
    }

    let sessionId: String?
    let options: JSON

    func json() throws -> JSON {

        return try JSON(encodable: self)
    }
}
