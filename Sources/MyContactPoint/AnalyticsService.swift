//
//  AnalyticsService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func trackEvent(_ eventName: String, properties: [String: Any] = [:]) {
        // TODO: Implement PostHog integration
        print("Analytics Event: \(eventName)")
        if !properties.isEmpty {
            print("Properties: \(properties)")
        }
    }
    
    func trackTutorialStarted() {
        trackEvent("tutorial_started")
    }
    
    func trackTutorialSlideViewed(slideNumber: Int, slideName: String) {
        trackEvent("tutorial_slide_viewed", properties: [
            "slide_number": slideNumber,
            "slide_name": slideName
        ])
    }
    
    func trackTutorialCompleted() {
        trackEvent("tutorial_completed")
    }
    
    func trackTutorialSkipped() {
        trackEvent("tutorial_skipped")
    }
    
    func trackAppLaunched() {
        trackEvent("app_launched")
    }
}
