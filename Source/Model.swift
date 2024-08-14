/**
 * Copyright (c) Facebook, Inc. and Microsoft Corporation.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import CoreML
import Foundation

enum Model {
  case StarryNight
  case Candy
  case Mosaic
  case RainPrincess
  case Udnie

  var MLModel: MLModel {
    switch self {
    case .StarryNight: return starrynight().model
    case .Candy: return candy().model
    case .Mosaic: return mosaic().model
    case .RainPrincess: return rain_princess().model
    case .Udnie: return udnie().model
    }
  }

  var nextModel: Model {
    switch self {
    case .StarryNight: return .Candy
    case .Candy: return .Mosaic
    case .Mosaic: return .RainPrincess
    case .RainPrincess: return .Udnie
    case .Udnie: return .StarryNight
    }
  }

  var artist: String {
    switch self {
    case .StarryNight: return "Vincent Van Gogh"
    case .Candy: return "Natasha Westcoat"
    case .Mosaic: return ""
    case .RainPrincess: return "Leonid Afremov"
    case .Udnie: return "Francis Picabia"
    }
  }

  var nameModel: String {
    switch self {
    case .StarryNight: return "Starry Night"
    case .Candy: return "Candy"
    case .Mosaic: return "Mosaic"
    case .RainPrincess: return "Rain Princess"
    case .Udnie: return "Udnie"
    }
  }
}
