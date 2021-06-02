//
//  RicohThetaProviderDelegate.swift
//  RicohTheta
//
//  Created by Majd Sabah on 31/05/2021.
//

public protocol RicohThetaProviderDelegate: AnyObject {

    /// Ricoh theta state delegate
    /// - Parameter state: state enum
    func thetaCamera(state: RicohThetaState)

    /// Theta camera progress delegate
    /// - Parameter progress: progress value, from 0.00 up to 1.00
    func thetaCamera(progress: CGFloat)

    /// Theta camera image delegate
    /// - Parameter image: image object
    func thetaCamera(image: UIImage)

    /// Theta camera live preview delegate
    /// - Parameter livePreview: image object
    func thetaCamera(livePreview: UIImage)

    /// Theta camera get option result delegate
    /// - Parameter options: image object
    func thetaCamera(optionsDTO: OptionDTO)

    /// Theta camera set option result delegate
    /// - Parameters:
    ///   - option: option that trying to set
    ///   - value: option value
    ///   - error: error of setting option
    func thetaCamera(option: OptionPayload.Option, value: Any, error: Error?)

    /// Theta camera error delegate
    /// - Parameter error: error object
    func thetaCamera(error: Error)
}
