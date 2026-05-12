//
//  Feedback.swift
//  StatKeeper
//
//  Centralized haptic and (optional) sound feedback utilities.
//
//  Copyright © 2026 Kenny Gruchalla
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import UIKit
import AudioToolbox

/// A namespace for haptic and sound feedback used throughout the app.
enum Feedback {

    /// A light impact haptic suitable for simple taps (e.g., incrementing a counter).
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()             // Pre-warms the Taptic Engine for lower latency
        generator.impactOccurred()
    }

    /// A heavier impact haptic for stronger emphasis (e.g., destructive or important taps).
    static func heavyTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// A notification haptic indicating success (e.g., saved or copied).
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// A notification haptic indicating a warning (non-fatal issue).
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// A notification haptic indicating an error (operation failed).
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    /// Plays a subtle click sound (“Tink”) t
    static func clickSound() {
        AudioServicesPlaySystemSound(1104)
    }

    /// Plays a subtle delete/backspace sound.
    static func deleteSound() {
        AudioServicesPlaySystemSound(1123)
    }

    /// A light tap haptic paired with a subtle click sound.
    static func tapWithSound() {
        tap()
        clickSound()
    }

    /// A heavier impact paired with a delete sound.
    static func deleteWithSound() {
        heavyTap()
        deleteSound()
    }

    /// A success haptic paired with a soft click, intended for copy/save confirmations.
    static func copied() {
        success()
        clickSound()
    }
}
