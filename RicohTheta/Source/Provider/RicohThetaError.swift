//
//  RicohThetaError.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

/// Ricoh theta error
public enum RicohThetaError: Error, CustomDebugStringConvertible {

    case cameraAPIError
    case cameraNotConnected
    case cameraIsExecuting
    case cameraCommanderNotExists
    case cameraSessionNotExists
    case cameraCommandNotExists
    case cameraCommandIdNotExists
    case cameraFileUrlNotExists
    case cameraInvalidFileUrl
    case cameraDownloadImageUrlNotExists
    case cameraDownloadImageDataNotExists
    case cameraDownloadImageNotExists
    case cameraOptionsNotAvailable

    public var debugDescription: String {
        switch self {
        case .cameraAPIError:
            return "cameraAPIError"
        case .cameraNotConnected:
            return "cameraNotConnected"
        case .cameraIsExecuting:
            return "cameraIsExecuting"
        case .cameraCommanderNotExists:
            return "cameraCommanderNotExists"
        case .cameraSessionNotExists:
            return "cameraSessionNotExists"
        case .cameraCommandNotExists:
            return "cameraCommandNotExists"
        case .cameraCommandIdNotExists:
            return "cameraCommandIdNotExists"
        case .cameraFileUrlNotExists:
            return "cameraFileUrlNotExists"
        case .cameraInvalidFileUrl:
            return "cameraInvalidFileUrl"
        case .cameraDownloadImageUrlNotExists:
            return "cameraDownloadImageUrlNotExists"
        case .cameraDownloadImageDataNotExists:
            return "cameraDownloadImageDataNotExists"
        case .cameraDownloadImageNotExists:
            return "cameraDownloadImageNotExists"
        case .cameraOptionsNotAvailable:
            return "cameraOptionsNotAvailable"
        }
    }
}
