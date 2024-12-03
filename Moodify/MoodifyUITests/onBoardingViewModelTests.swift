/*
 OnboardingViewModelTests.swift
 Moodify
 
 Tests the functionality of the onboarding mood selection process, including:
 - Mood card navigation and transitions
 - Content validation for mood cards
 - Swipe gesture handling and boundaries
 - State management and initialization
 
 Created by Nazanin Mahmoudi on 11/18/24.
*/

import XCTest
@testable import Moodify

final class OnboardingMoodViewModelTests: XCTestCase {
    
    var viewModel: OnboardingMoodViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = OnboardingMoodViewModel()
    }
    
    /* Verifies that the view model initializes with correct default values */
    func testInitialState() {
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        XCTAssertFalse(viewModel.showGetStarted)
    }
    
    /* Validates the content of mood cards, ensuring correct number of moods
       and proper initialization of mood properties */
    func testMoodsContent() {
        /* Verify total number of mood options */
        XCTAssertEqual(viewModel.moods.count, 4)
        
        /* Validate first mood card content */
        let firstMood = viewModel.moods[0]
        XCTAssertEqual(firstMood.mood.name, "Happy")
        XCTAssertEqual(firstMood.mood.icon, "sun.max.fill")
        XCTAssertFalse(firstMood.message.isEmpty)
        
        /* Validate last mood card content */
        let lastMood = viewModel.moods[3]
        XCTAssertEqual(lastMood.mood.name, "Sad")
        XCTAssertEqual(lastMood.mood.icon, "cloud.drizzle.fill")
        XCTAssertFalse(lastMood.message.isEmpty)
    }
    
    /* Tests forward navigation through mood cards and transition to get started state */
    func testNextMoodNavigation() {
        /* Test standard forward navigation */
        viewModel.nextMood()
        XCTAssertEqual(viewModel.currentIndex, 1)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        
        /* Navigate to final card */
        viewModel.nextMood()
        viewModel.nextMood()
        XCTAssertEqual(viewModel.currentIndex, 3)
        
        /* Verify transition to get started state */
        viewModel.nextMood()
        XCTAssertTrue(viewModel.showGetStarted)
    }
    
    /* Tests backward navigation through mood cards and boundary conditions */
    func testPreviousMoodNavigation() {
        /* Setup initial position */
        viewModel.currentIndex = 3
        
        /* Test standard backward navigation */
        viewModel.previousMood()
        XCTAssertEqual(viewModel.currentIndex, 2)
        XCTAssertEqual(viewModel.dragOffset, .zero)
        
        /* Verify can't navigate before first card */
        viewModel.currentIndex = 0
        viewModel.previousMood()
        XCTAssertEqual(viewModel.currentIndex, 0)
    }
    
    /* Tests gesture-based navigation with different drag distances and directions */
    func testDragGestureHandling() {
        /* Test right swipe for previous card */
        let rightDrag = MockDragGesture(translation: CGSize(width: 100, height: 0))
        viewModel.currentIndex = 1
        viewModel.handleDragEnd(gesture: rightDrag, maxIndex: 3)
        XCTAssertEqual(viewModel.currentIndex, 0)
        
        /* Test left swipe for next card */
        let leftDrag = MockDragGesture(translation: CGSize(width: -100, height: 0))
        viewModel.handleDragEnd(gesture: leftDrag, maxIndex: 3)
        XCTAssertEqual(viewModel.currentIndex, 1)
        
        /* Verify small drags don't trigger navigation */
        let smallDrag = MockDragGesture(translation: CGSize(width: 30, height: 0))
        viewModel.handleDragEnd(gesture: smallDrag, maxIndex: 3)
        XCTAssertEqual(viewModel.currentIndex, 1)
    }
    
    /* Tests that drag gestures respect navigation boundaries */
    func testDragGestureBoundaries() {
        /* Verify can't drag before first card */
        let rightDrag = MockDragGesture(translation: CGSize(width: 100, height: 0))
        viewModel.currentIndex = 0
        viewModel.handleDragEnd(gesture: rightDrag, maxIndex: 3)
        XCTAssertEqual(viewModel.currentIndex, 0)
        
        /* Verify can't drag past last card */
        let leftDrag = MockDragGesture(translation: CGSize(width: -100, height: 0))
        viewModel.currentIndex = 3
        viewModel.handleDragEnd(gesture: leftDrag, maxIndex: 3)
        XCTAssertEqual(viewModel.currentIndex, 3)
    }
}

/* Mock implementation of DragGestureType for testing gesture handling */
struct MockDragGesture: DragGestureType {
    let translation: CGSize
}
