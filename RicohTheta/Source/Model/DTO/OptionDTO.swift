//
//  OptionDTO.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

import GenericJSON

// swiftlint:disable identifier_name

/// Option DTO
public struct OptionDTO: Codable {

    public let whiteBalance: String?
    public let whiteBalanceSupport: [String]?

    public let iso: Int?
    public let isoSupport: [Int]?

    public let _filter: String?
    public let _filterSupport: [String]?

    public let _colorTemperature: Int?
    public let _colorTemperatureSupport: ColorTemperature?

    init(json: JSON) {

        guard let options = json["options"] else {

            self.whiteBalance = nil
            self.whiteBalanceSupport = nil

            self.iso = nil
            self.isoSupport = nil

            self._filter = nil
            self._filterSupport = nil

            self._colorTemperature = nil
            self._colorTemperatureSupport = nil
            return
        }

        self.whiteBalance = options[OptionPayload.Option.whiteBalance.rawValue]?.stringValue
        self.whiteBalanceSupport = options[OptionPayload.Option.whiteBalance.support]?
            .arrayValue?
            .compactMap({ $0.stringValue })

        let isoValue = options[OptionPayload.Option.iso.rawValue]?.doubleValue
        self.iso = isoValue == nil ? nil : Int(isoValue!)
        self.isoSupport = options[OptionPayload.Option.iso.support]?.arrayValue?.compactMap({

            let isoValue = $0.doubleValue
            return isoValue == nil ? nil : Int(isoValue!)
        })

        self._filter = options[OptionPayload.Option.filter.rawValue]?.stringValue
        self._filterSupport = options[OptionPayload.Option.filter.support]?.arrayValue?.compactMap({ $0.stringValue })

        let colorValue = options[OptionPayload.Option.colorTemperature.rawValue]?.doubleValue
        self._colorTemperature = colorValue == nil ? nil : Int(colorValue!)
        self._colorTemperatureSupport = ColorTemperature(json: options[OptionPayload.Option.colorTemperature.support])
    }
}

public struct ColorTemperature: Codable {

    public let stepSize: Int?
    public let minTemperature: Int?
    public let maxTemperature: Int?

    init(json: JSON?) {

        let stepSizeValue = json?[ColorTemperature.CodingKeys.stepSize.stringValue]?.doubleValue
        let minTemperatureValue = json?[ColorTemperature.CodingKeys.minTemperature.stringValue]?.doubleValue
        let maxTemperatureValue = json?[ColorTemperature.CodingKeys.maxTemperature.stringValue]?.doubleValue

        self.stepSize = stepSizeValue == nil ? nil : Int(stepSizeValue!)
        self.minTemperature = minTemperatureValue == nil ? nil : Int(minTemperatureValue!)
        self.maxTemperature = maxTemperatureValue == nil ? nil : Int(maxTemperatureValue!)
    }
}
