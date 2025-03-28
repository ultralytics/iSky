// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

//
//  Model2.swift
//  iSky
//
//  Created by Glenn Jocher on 15/12/2018.
//  Copyright © 2018 Facebook Inc. All rights reserved.
//

import CoreML
import Foundation

enum Model2 {
  case StarryNight
  case Candy
  case Mosaic
  case RainPrincess
  case Udnie

  var model = starrynight().model

}
