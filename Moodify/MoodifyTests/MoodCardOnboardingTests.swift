/*
 GetStartedCardTests.swift
 Moodify
 
 Tests the functionality of the get started card view, including
 button interactions and view content verification.
 
 Created by Nazanin Mahmoudi
*/

import XCTest
import SwiftUI
@testable import Moodify

final class GetStartedCardTests: XCTestCase {
    /* Tests button action execution */
    func testButtonAction() {
        var actionCalled = false
        let expectation = XCTestExpectation(description: "Button action called")
        
        let card = GetStartedCard {
            actionCalled = true
            expectation.fulfill()
        }
        
        /* Simulate view rendering */
        let view = card.body
        
        /* Find and trigger the button action */
        if let button = findButtonAction(in: view) {
            button()
            
            /* Wait briefly for animation */
            wait(for: [expectation], timeout: 0.2)
            
            XCTAssertTrue(actionCalled, "Button action should have been called")
        } else {
            XCTFail("Failed to find action button in view hierarchy")
        }
    }
    
    /* Tests view content and structure */
    func testViewContent() {
        let card = GetStartedCard {}
        let view = card.body
        
        /* Verify text content exists */
        XCTAssertTrue(containsText(view, "Ready to Begin?"))
        XCTAssertTrue(containsText(view, "Tap the button to get started"))
        
        /* Verify button exists with correct icon */
        XCTAssertTrue(containsImage(view, systemName: "arrow.right.circle.fill"))
    }
    
    /* Helper method to find button action in view hierarchy */
    private func findButtonAction(in view: some View) -> (() -> Void)? {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let button = child.value as? Button<Image> {
                let buttonMirror = Mirror(reflecting: button)
                for case let (label?, value) in buttonMirror.children {
                    if label == "_action" {
                        return value as? () -> Void
                    }
                }
            }
        }
        return nil
    }
    
    /* Helper method to check if view contains specific text */
    private func containsText(_ view: some View, _ text: String) -> Bool {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let textView = child.value as? Text,
               let stringValue = Mirror(reflecting: textView).children.first?.value as? String,
               stringValue == text {
                return true
            }
        }
        return false
    }
    
    /* Helper method to check if view contains specific system image */
    private func containsImage(_ view: some View, systemName: String) -> Bool {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let image = child.value as? Image,
               let uiImage = image as? Image,
               Mirror(reflecting: uiImage).children.contains(where: { $0.value as? String == systemName }) {
                return true
            }
        }
        return false
    }
}
