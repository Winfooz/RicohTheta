//
//  DeviceInfoDTO.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

/// DeviceInfo DTO
public struct DeviceInfoDTO: Codable {

    public let manufacturer: String?
    public let model: String?
    public let serialNumber: String?
    public let firmwareVersion: String?
    public let supportUrl: String?
    public let gps: Bool?
    public let gyro: Bool?
    public let uptime: Int?
    public let api: [String]?
    public let endpoints: EndPoint?
    public let apiLevel: [Int]?
}

public struct EndPoint: Codable {

    public let httpPort: Int?
    public let httpUpdatesPort: Int?
}
