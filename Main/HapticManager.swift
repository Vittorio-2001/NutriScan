//
//  HapticManager.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import UIKit
import AudioToolbox

struct HapticManager {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057) // piccolo beep
    }
}
