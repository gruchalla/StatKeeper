//
//  Feedback.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import Foundation
import UIKit
import AudioToolbox

enum Feedback {

    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func heavyTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    static func clickSound() {
        // 1104: "Tink" standard click
        AudioServicesPlaySystemSound(1104)
    }

    static func deleteSound() {
        // 1123: delete key sound
        AudioServicesPlaySystemSound(1123)
    }

    static func tapWithSound() {
        tap()
        clickSound()
    }

    static func deleteWithSound() {
        heavyTap()
        deleteSound()
    }

    static func copied() {
        // For copy actions: a gentle success haptic with a soft click
        success()
        clickSound()
    }
}
