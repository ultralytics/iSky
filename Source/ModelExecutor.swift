// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

/**
 * Copyright (c) Facebook, Inc. and Microsoft Corporation.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import CoreML
import Foundation
import Vision

final class ModelExecutor {

  typealias ExecutionHandler = (DispatchQueue, (CVPixelBuffer?, Error?) -> Void)

  fileprivate let queue = DispatchQueue(
    label: "com.facebook.onnx.modelExecutor",
    qos: .userInitiated)
  fileprivate let vnModel: VNCoreMLModel
  fileprivate let vnRequest: VNCoreMLRequest

  init(
    for model: Model,
    executionHandler: ExecutionHandler
  ) throws {
    self.vnModel = try VNCoreMLModel(for: model.MLModel)
    self.vnRequest = VNCoreMLRequest(model: vnModel, completionHandler: executionHandler)
    self.vnRequest.imageCropAndScaleOption = .scaleFill
  }

  func execute(with pixelBuffer: CVPixelBuffer) {
    queue.sync {
      let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
      try? handler.perform([self.vnRequest])
    }
  }

  func executeAsync(with pixelBuffer: CVPixelBuffer) {
    queue.async {
      let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
      try? handler.perform([self.vnRequest])
    }
  }
}

extension VNCoreMLRequest {
  fileprivate convenience init(
    model: VNCoreMLModel, completionHandler: ModelExecutor.ExecutionHandler
  ) {
    self.init(model: model) { (request, error) in
      if let error = error {
        completionHandler.0.async {
          completionHandler.1(nil, error)
        }
        return
      }

      guard
        let results = request.results as? [VNPixelBufferObservation],
        let result = results.first
      else {
        // TODO: Error handling here
        return
      }

      completionHandler.0.async {
        completionHandler.1(result.pixelBuffer, nil)
      }
    }
  }
}
