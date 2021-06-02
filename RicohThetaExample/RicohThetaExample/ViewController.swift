//
//  ViewController.swift
//  RicohThetaExample
//
//  Created by Majd Sabah on 31/05/2021.
//

import UIKit
import RicohTheta

class ViewController: UIViewController {

    @IBOutlet weak var cameraStatusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var showOptionsButton: UIButton!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var livePreviewButton: UIButton!

    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var imagePlaceholderLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!

    private weak var leftButton: UIBarButtonItem?
    private weak var titleButton: UIBarButtonItem?
    private weak var rightButton: UIBarButtonItem?

    private lazy var textView: UITextView = {

        let textView = UITextView()

        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textView.inputView = pickerView

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(self.inputAccessoryDoneAction))

        let flexLeftButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil)

        let titleButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.titleButton = titleButton

        let flexRightButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil)

        let leftButton = UIBarButtonItem(
            title: "〈",
            style: .plain,
            target: self,
            action: #selector(self.inputAccessoryLeftAction))
        self.leftButton = leftButton

        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: self,
            action: nil)
        spaceButton.width = 20

        let rightButton = UIBarButtonItem(
            title: "〉",
            style: .plain,
            target: self,
            action: #selector(self.inputAccessoryRightAction))
        self.rightButton = rightButton

        toolBar.setItems(
            [
                leftButton,
                spaceButton,
                rightButton,
                flexLeftButton,
                titleButton,
                flexRightButton,
                doneButton],
            animated: false)
        textView.inputAccessoryView = toolBar

        textView.text = ""
        return textView
    }()

    private var options: [Options] = []
    private var selectedOption: Int = 0 {
        didSet {
            self.leftButton?.isEnabled = self.selectedOption != 0
            self.titleButton?.title = self.options[self.selectedOption].option.rawValue
            self.rightButton?.isEnabled = self.selectedOption != (self.options.count - 1)
        }
    }

    struct Options {

        let option: OptionPayload.Option
        let values: [Any]
    }

    let thetaCameraProvider: RicohThetaProvider = RicohThetaProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.thetaCameraProvider.delegate = self
        self.view.addSubview(self.textView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.connect(self.connectButton)
    }

    @IBAction
    func connect(_ sender: UIButton) {

        self.logging("clicked \(sender.titleLabel?.text ?? "")")
        self.thetaCameraProvider.connect()
    }

    @IBAction
    func showOptions(_ sender: UIButton) {

        self.thetaCameraProvider.getAvailableOptions()
    }

    @IBAction
    func takePicture(_ sender: UIButton) {

        self.logging("clicked \(sender.titleLabel?.text ?? "")")
        self.thetaCameraProvider.takePicture()
    }

    @IBAction
    func livePreview(_ sender: UIButton) {

        self.logging("clicked \(sender.titleLabel?.text ?? "")")
        self.thetaCameraProvider.livePreview()
    }

    @IBAction
    func dismiss(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: RicohThetaProviderDelegate {

    func thetaCamera(state: RicohThetaState) {

        self.cameraStatusLabel.text = state.rawValue

        switch state {
        case .notConnected:
            self.connectButton.isEnabled = true
            self.takePictureButton.isEnabled = false
            self.showOptionsButton.isEnabled = false
            self.livePreviewButton.isEnabled = false
        case .connecting:
            self.connectButton.isEnabled = false
            self.takePictureButton.isEnabled = false
            self.showOptionsButton.isEnabled = false
            self.livePreviewButton.isEnabled = false
        case .idle:
            self.connectButton.isEnabled = false
            self.takePictureButton.isEnabled = true
            self.showOptionsButton.isEnabled = true
            self.livePreviewButton.isEnabled = true

            self.livePreview(self.livePreviewButton)
        case .executing:
            self.connectButton.isEnabled = false
            self.takePictureButton.isEnabled = false
            self.showOptionsButton.isEnabled = false
            self.livePreviewButton.isEnabled = false

        case .livePreviewing:
            print("livePreviewing")

            self.livePreviewButton.isEnabled = false
        }

        self.logging("Camera now is \(state.rawValue)")
    }

    func thetaCamera(progress: CGFloat) {

        if !self.activityIndicatorView.isAnimating {
            self.activityIndicatorView.startAnimating()
        }

        self.progressView.setProgress(Float(progress), animated: true)
        self.logging("downloading image from camera \(progress)")
    }

    func thetaCamera(image: UIImage) {

        self.activityIndicatorView.stopAnimating()
        self.progressView.setProgress(0.0, animated: false)
        self.imagePlaceholderLabel.isHidden = true

        self.resultImageView.image = image

        if let data = image.jpegData(compressionQuality: 1) {

            let byteCountFormatter = ByteCountFormatter()
            byteCountFormatter.allowedUnits = [.useKB, .useMB]
            byteCountFormatter.countStyle = .file
            let countString = byteCountFormatter.string(fromByteCount: Int64(data.count))

            self.logging("Image downloaded from camera \(countString) WxH \(image.size)")
        }
    }

    func thetaCamera(livePreview: UIImage) {

        self.activityIndicatorView.stopAnimating()
        self.progressView.setProgress(0.0, animated: false)
        self.imagePlaceholderLabel.isHidden = true
        self.progressView.isHidden = true

        self.livePreviewButton.isEnabled = false
        self.resultImageView.image = livePreview
    }

    func thetaCamera(optionsDTO: OptionDTO) {

        self.options.removeAll()

        self.options.append(Options(option: .whiteBalance, values: (optionsDTO.whiteBalanceSupport ?? [])))
        self.options.append(Options(option: .filter, values: (optionsDTO._filterSupport ?? [])))
        self.options.append(Options(option: .iso, values: (optionsDTO.isoSupport ?? [])))

        if self.options.isEmpty {
            return
        }

        self.selectedOption = 0
        self.setSelectedOption(at: 0)
        (self.textView.inputView as? UIPickerView)?.reloadAllComponents()
        (self.textView.inputView as? UIPickerView)?.selectRow(0, inComponent: 0, animated: true)
        self.textView.becomeFirstResponder()
    }

    func thetaCamera(option: OptionPayload.Option, value: Any, error: Error?) {

        // Update UI
        print(option, value, error?.localizedDescription ?? "")
    }

    func thetaCamera(error: Error) {

        self.activityIndicatorView.stopAnimating()
        self.progressView.setProgress(0.0, animated: false)
        self.logging("Error: \(Date().time), \((error as NSError).debugDescription)")
    }

    private func logging(_ newLog: String) {

        guard let textString = logTextView.text else {
            return
        }

        let newText = textString + "\n" + newLog

        self.logTextView.text = newText
        self.scrollToBottom()
    }

    private func scrollToBottom() {

        if self.logTextView.text.count > 0 {
            let location = self.logTextView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }
}

extension Date {

    var time: String {

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss"
        return dateFormatterGet.string(from: self)
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    @objc
    func inputAccessoryLeftAction() {

        self.selectedOption -= 1
        self.setSelectedOption(at: 0)
        (self.textView.inputView as? UIPickerView)?.reloadAllComponents()
        (self.textView.inputView as? UIPickerView)?.selectRow(0, inComponent: 0, animated: true)
    }

    @objc
    func inputAccessoryRightAction() {

        self.selectedOption += 1
        self.setSelectedOption(at: 0)
        (self.textView.inputView as? UIPickerView)?.reloadAllComponents()
        (self.textView.inputView as? UIPickerView)?.selectRow(0, inComponent: 0, animated: true)
    }

    @objc
    func inputAccessoryDoneAction() {

        self.textView.resignFirstResponder()
        guard let text = self.textView.text else {
            return
        }

        let option = self.options[self.textView.tag]
        self.thetaCameraProvider.setOption(option.option, value: text)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return self.options[self.selectedOption].values.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return "\(self.options[self.selectedOption].values[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        self.setSelectedOption(at: row)
    }

    private func setSelectedOption(at row: Int) {

        self.textView.tag = self.selectedOption
        self.textView.text = "\(self.options[self.selectedOption].values[row])"
    }
}

