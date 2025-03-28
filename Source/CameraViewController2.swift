// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

//
//  CameraViewController2.swift
//  iSky
//
//  Created by Glenn Jocher on 10/12/2018.
//  Copyright © 2018 Facebook Inc. All rights reserved.
//

import AVKit
import CoreML
import MobileCoreServices
import UIKit
import Vision

class CameraViewController2: UIViewController {
  @IBOutlet var imageView2: UIImageView!

  var captureSession: AVCaptureSession?
  let videoOutputQueue = DispatchQueue(
    label: "com.facebook.onnx.videoOutputQueue", qos: .userInitiated)

  var model = Model.StarryNight
  var modelExecutor: ModelExecutor?

  override func viewDidLoad() {
    super.viewDidLoad()

    //imageView2 = UIImageView()
    imageView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
    imageView2.image = UIImage(named: "the_city_london.udnie.jpg")
    // imageView2.contentMode = .scaleAspectFit
    // self.view = imageView2

  }

}
