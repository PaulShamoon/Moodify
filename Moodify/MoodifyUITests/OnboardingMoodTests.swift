/*
 OnboardingMoodTests.swift
 Moodify
 
 Tests the functionality of mood card navigation, including swipe gestures,
 content verification, and state management.
 
 Created by Nazanin Mahmoudi on 11/18/24.
*/

import XCTest
import SwiftUI
@testable import Moodify

final class OnboardingMoodTests: XCTestCase {
    var viewModel: OnboardingMoodViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = OnboardingMoodViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    /* Tests initial state of the view model */
    func testInitialState() {
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        XCTAssertFalse(viewModel.showGetStarted)
        XCTAssertEqual(viewModel.moods.count, 4)
    }
    
    /* Tests forward navigation through moods */
    func testNextMood() {
        /* Normal case */
        viewModel.nextMood()
        XCTAssertEqual(viewModel.currentIndex, 1)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        XCTAssertFalse(viewModel.showGetStarted)
        
        /* End case */
        viewModel.currentIndex = viewModel.moods.count - 1
        viewModel.nextMood()
        XCTAssertTrue(viewModel.showGetStarted)
    }
    
    /* Tests backward navigation through moods */
    func testPreviousMood() {
        /* Set initial state */
        viewModel.currentIndex = 2
        
        /* Normal case */
        viewModel.previousMood()
        XCTAssertEqual(viewModel.currentIndex, 1)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        
        /* Start case */
        viewModel.currentIndex = 0
        viewModel.previousMood()
        XCTAssertEqual(viewModel.currentIndex, 0)
    }
    
    /* Mock drag gesture for testing swipe interactions */
    private struct MockDragGesture: DragGestureType {
        var translation: CGSize
        
        init(translation: CGSize = .zero) {
            self.translation = translation
        }
    }

    /* Tests swipe gesture handling for mood navigation */
    func testHandleDragEnd() {
        /* Test right swipe (previous mood) */
        let rightSwipe = MockDragGesture(translation: CGSize(width: 100, height: 0))
        viewModel.currentIndex = 1
        viewModel.handleDragEnd(gesture: rightSwipe, maxIndex: viewModel.moods.count)
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        
        /* Test left swipe (next mood) */
        let leftSwipe = MockDragGesture(translation: CGSize(width: -100, height: 0))
        viewModel.handleDragEnd(gesture: leftSwipe, maxIndex: viewModel.moods.count)
        XCTAssertEqual(viewModel.currentIndex, 1)
        
        /* Test small drag (should not change page) */
        let smallDrag = MockDragGesture(translation: CGSize(width: 30, height: 0))
        let previousIndex = viewModel.currentIndex
        viewModel.handleDragEnd(gesture: smallDrag, maxIndex: viewModel.moods.count)
        XCTAssertEqual(viewModel.currentIndex, previousIndex)
    }
    
    /* Tests mood data content and ordering */
    func testMoodContent() {
        /* First mood */
        XCTAssertEqual(viewModel.moods[0].mood.name, "Happy")
        XCTAssertEqual(viewModel.moods[0].mood.icon, "sun.max.fill")
        
        /* Last mood */
        let lastIndex = viewModel.moods.count - 1
        XCTAssertEqual(viewModel.moods[lastIndex].mood.name, "Sad")
        XCTAssertEqual(viewModel.moods[lastIndex].mood.icon, "cloud.drizzle.fill")
    }
}
