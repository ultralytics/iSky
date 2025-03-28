// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

/**
 * Copyright (c) Facebook, Inc. and Microsoft Corporation.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import AVKit
import CoreML
import MobileCoreServices
import UIKit
import Vision

class CameraViewController1: UIViewController {
  //var imageView2: UIImageView!
  @IBOutlet var imageView2: UIImageView!
  @IBOutlet var imageView3: UIImageView!

  @IBOutlet var label0: UILabel!
  @IBOutlet var label1: UILabel!
  @IBOutlet var label2: UILabel!

  @IBOutlet var pauseButtonOutlet: UIBarButtonItem!
  @IBOutlet var playButtonOutlet: UIBarButtonItem!

  var captureSession: AVCaptureSession?
  let videoOutputQueue = DispatchQueue(
    label: "com.facebook.onnx.videoOutputQueue", qos: .userInitiated)

  var model = Model.StarryNight
  var modelExecutor: ModelExecutor?

  ///--------------------------------------
  // MARK: - View
  ///--------------------------------------

  override func viewDidLoad() {
    super.viewDidLoad()

    // imageView2 = UIImageView()
    imageView2.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(switchToNextModel)))
    imageView2.isUserInteractionEnabled = true
    imageView2.contentMode = .scaleAspectFill
    // self.view = imageView2

    setupExecutor(for: model)
    prepareCaptureSession()

    label0.text = ""
    label1.text = model.nameModel
    label2.text = model.artist
    imageView3.image = UIImage(named: model.nameModel + ".jpg")
  }

  ///--------------------------------------
  // MARK: - Actions
  ///--------------------------------------

  @objc func switchToNextModel() {
    // Capture model into local stack variable to make everything synchronized.
    let model = self.model.nextModel
    self.model = model

    label1.text = model.nameModel
    label2.text = model.artist
    imageView3.image = UIImage(named: model.nameModel + ".jpg")

    // Stop the session and start it after we switch the model
    // All in all, this makes sure we switch fast and are not blocked by running the model.
    captureSession?.stopRunning()

    videoOutputQueue.async {
      self.modelExecutor = nil
      self.setupExecutor(for: model)

      DispatchQueue.main.async {
        self.playButton("")
      }
    }
  }

  ///--------------------------------------
  // MARK: - Setup
  ///--------------------------------------

  fileprivate func setupExecutor(for model: Model) {
    // Make sure we destroy existing executor before creating a new one.
    modelExecutor = nil

    // Create new one and store it in a var
    modelExecutor = try? ModelExecutor(
      for: model,
      executionHandler: (DispatchQueue.main, didGetPredictionResult))
  }

  @IBAction func playButton(_ sender: Any) {
    captureSession?.startRunning()

    playButtonOutlet.isEnabled = false
    pauseButtonOutlet.isEnabled = true
  }

  @IBAction func pauseButton(_ sender: Any) {
    captureSession?.stopRunning()

    playButtonOutlet.isEnabled = true
    pauseButtonOutlet.isEnabled = false
  }

  @IBAction func cameraButton(_ sender: Any) {
    label0.text = "Saving..."

    //let img = UIImage(named: "the_city_london.udnie.jpg")!
    let img: UIImage = imageView2.image!

    let activityViewController = UIActivityViewController(
      activityItems: [img], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view
    self.present(activityViewController, animated: true, completion: nil)

    label0.text = ""
  }

  // share image
  @IBAction func shareImageButton(_ sender: Any) {
    //let bounds = UIScreen.main.bounds
    let bounds = imageView2.bounds
    UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
    imageView2.drawHierarchy(in: bounds, afterScreenUpdates: false)  // self.view.drawHierarchy()
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let activityViewController = UIActivityViewController(
      activityItems: [img!], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = imageView2
    self.present(activityViewController, animated: true, completion: nil)

    playButton("")
  }

  // share screenshot
  @IBAction func saveScreenshotButton(_ sender: Any) {
    // let layer = UIApplication.shared.keyWindow!.layer
    // let scale = UIScreen.main.scale
    // UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    // layer.render(in: UIGraphicsGetCurrentContext()!)
    // let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    // UIGraphicsEndImageContext()
    let screenshot = UIApplication.shared.screenShot
    UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
  }

  fileprivate func prepareCaptureSession() {
    guard self.captureSession == nil else { return }

    let captureSession = AVCaptureSession()
    captureSession.sessionPreset = .photo

    // let defaultCamera = AVCaptureDevice.default(for: .video)!
    // let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
    let backCamera = AVCaptureDevice.default(
      .builtInWideAngleCamera, for: AVMediaType.video, position: .back)!

    let input = try! AVCaptureDeviceInput(device: backCamera)

    captureSession.addInput(input)

    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
    captureSession.addOutput(videoOutput)

    if let videoOutputConnection = videoOutput.connection(with: .video) {
      videoOutputConnection.videoOrientation = .portrait
    }

    captureSession.startRunning()
    self.captureSession = captureSession
  }

  ///--------------------------------------
  // MARK: - Prediction
  ///--------------------------------------

  fileprivate func predict(_ pixelBuffer: CVPixelBuffer) {
    guard let modelExecutor = modelExecutor else {
      DispatchQueue.main.async {
        self.didGetPredictionResult(pixelBuffer: pixelBuffer, error: nil)
      }
      return
    }
    modelExecutor.execute(with: pixelBuffer)
  }

  fileprivate func didGetPredictionResult(pixelBuffer: CVPixelBuffer?, error: Error?) {
    guard let pixelBuffer = pixelBuffer else {
      print("Failed to get prediction result with error \(String(describing: error))")
      return
    }

    imageView2.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
    //imageView2.image = UIImage(named: "the_city_london.udnie.jpg")
  }
}

///--------------------------------------
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
///--------------------------------------

extension CameraViewController1: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    predict(pixelBuffer)
  }
}
