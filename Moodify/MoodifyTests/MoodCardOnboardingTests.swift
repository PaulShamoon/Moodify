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
        let expectation = self.expectation(description: "Button tapped")
        
        let card = GetStartedCard {
            actionCalled = true
            expectation.fulfill()
        }
        
        // Simulate button tap
        tapButton(in: card)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(actionCalled, "Button action should have been called")
    }
    
    /* Tests view content and structure */
    func testViewContent() {
        let card = GetStartedCard {}
        
        // Test presence of main elements
        XCTAssertNotNil(findText(in: card, "Ready to Begin?"))
        XCTAssertNotNil(findText(in: card, "Tap the button to get started"))
        XCTAssertNotNil(findButton(in: card))
    }
    
    // MARK: - Helper Methods
    
    private func tapButton(in view: GetStartedCard) {
        guard let button = findButton(in: view) else {
            XCTFail("Button not found")
            return
        }
        button.sendActions(for: .touchUpInside)
    }
    
    private func findButton(in view: GetStartedCard) -> UIButton? {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let hostingController = child.value as? UIHostingController<GetStartedCard> {
                return hostingController.view.subviews.first { $0 is UIButton } as? UIButton
            }
        }
        return nil
    }
    
    private func findText(in view: GetStartedCard, _ searchText: String) -> UILabel? {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let hostingController = child.value as? UIHostingController<GetStartedCard> {
                return hostingController.view.subviews.first {
                    ($0 as? UILabel)?.text == searchText
                } as? UILabel
            }
        }
        return nil
    }
}

// MARK: - View Helper Extension
extension GetStartedCard {
    func inspect() -> UIHostingController<GetStartedCard> {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.layoutIfNeeded()
        return hostingController
    }
}

