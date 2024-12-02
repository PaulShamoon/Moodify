/*
 OnboardingTests.swift
 Moodify
 
 Tests the functionality of the main onboarding flow, including:
 - Page navigation and transitions
 - Content validation for onboarding pages
 - Completion handling
 - Back navigation and boundary checks
 
 Created by Nazanin Mahmoudi on 11/18/24.
*/

import XCTest
@testable import Moodify

/* Test suite for the OnboardingViewModel which handles the main onboarding
   flow navigation and state management */
final class OnboardingTests: XCTestCase {
    
    /* Verifies that the view model initializes with correct default values */
    func testOnboardingInitialState() {
        let onboardingViewModel = OnboardingViewModel()
        
        /* Test initial state */
        XCTAssertEqual(onboardingViewModel.currentPage, 0)
        XCTAssertFalse(onboardingViewModel.showMoodView)
    }
    
    /* Tests forward navigation through onboarding pages */
    func testOnboardingNavigation() {
        let onboardingViewModel = OnboardingViewModel()
        
        /* Test moving to next page */
        onboardingViewModel.nextPage()
        XCTAssertEqual(onboardingViewModel.currentPage, 1)
        
        /* Test moving to last page */
        onboardingViewModel.nextPage()
        XCTAssertEqual(onboardingViewModel.currentPage, 2)
        
        /* Test completion behavior */
        onboardingViewModel.nextPage()
        XCTAssertTrue(onboardingViewModel.showMoodView)
    }
    
    /* Validates that completion handler is called when onboarding is finished */
    func testOnboardingCompletion() {
        let expectation = XCTestExpectation(description: "Completion handler called")
        
        let onboardingViewModel = OnboardingViewModel(onCompletion: {
            expectation.fulfill()
        })
        
        /* Navigate through all pages */
        onboardingViewModel.nextPage()
        onboardingViewModel.nextPage()
        onboardingViewModel.nextPage()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /* Verifies the content of onboarding pages */
    func testPageContent() {
        let onboardingViewModel = OnboardingViewModel()
        
        /* Test that we have the correct number of pages */
        XCTAssertEqual(onboardingViewModel.pages.count, 3)
        
        /* Test content of pages */
        XCTAssertFalse(onboardingViewModel.pages.isEmpty)
        
        /* Test first page content */
        let firstPage = onboardingViewModel.pages[0]
        XCTAssertFalse(firstPage.title.isEmpty)
        XCTAssertFalse(firstPage.description.isEmpty)
        XCTAssertFalse(firstPage.imageName.isEmpty)
    }
    
    /* Tests backward navigation and boundary conditions */
    func testBackNavigation() {
        let onboardingViewModel = OnboardingViewModel()
        
        /* Move forward two pages */
        onboardingViewModel.nextPage()
        onboardingViewModel.nextPage()
        XCTAssertEqual(onboardingViewModel.currentPage, 2)
        
        /* Test moving back */
        onboardingViewModel.previousPage()
        XCTAssertEqual(onboardingViewModel.currentPage, 1)
        
        /* Test can't go back before first page */
        onboardingViewModel.previousPage()
        onboardingViewModel.previousPage()
        XCTAssertEqual(onboardingViewModel.currentPage, 0)
    }
}
