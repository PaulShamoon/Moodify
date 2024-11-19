//
//  ProfileManagerTests.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/18/24.
//

import XCTest
@testable import Moodify


/*
 Class to test all the methods of the ProfileManager
 
 Assumption: Testing selectProfile is unnecessary as it involves
             only a straightforward variable assignment
 
 Created By: Paul Shamoon
 */
final class ProfileManagerTests: XCTestCase {
    var profileManager: ProfileManager!
    var profile1: Profile!
    var profile2: Profile!

    
    /*
     Method to setup all the data we
     need before each test runs
     
     Created By: Paul Shamoon
     */
    override func setUp() {
        super.setUp()
        
        // Initialize the profileManager
        profileManager = ProfileManager()
        
        // Initialize all the profileManagers profiles
        profileManager.profiles = SetupTestData.shared.profiles
        
        // Initialize the profiles
        profile1 = SetupTestData.shared.profile1
        profile2 = SetupTestData.shared.profile2
    }
    
    
    /*
     Method to tear down preset data
     after the completion of each test
     
     Created By: Paul Shamoon
     */
    override func tearDown() {
        profileManager = nil
        super.tearDown()
    }
    
    
    /*
     Method to test that the createProfile method of the profileManager
     behaves as expected and can properly create a profile
     
     Created By: Paul Shamoon
     */
    func testCreateProfile() -> Void {
        let originalProfiles = profileManager.profiles
        
        // Create a new profile
        profileManager.createProfile(
            name: "user4",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
            favoriteGenres: ["Dance", "Soul"],
            hasAgreedToTerms: true
        )
        
        // Get the updated state of the profileManagers profiles
        let newProfiles = profileManager.profiles
        
        // Get the newly created profile
        let createdProfile = newProfiles.last { !originalProfiles.contains($0) }
        
        // Ensure that the newly created profile exists
        XCTAssertNotNil(createdProfile, "The createdProfile does not exist")

        // Ensure that the total amount of profiles are now 4
        XCTAssertEqual(newProfiles.count, 4, "The total amount of profiles should be 4")
        
        // Ensure that the created profile is user4
        XCTAssertEqual(createdProfile?.name, "user4", "The name of the created profile should be user4")

        // Ensure that originalProfiles does not equal newProfiles since we created a new profile
        XCTAssertNotEqual(originalProfiles, newProfiles, "The old and new state of profiles should not be equal.")
    }
    
    
    /*
     Method to test that the updateProfile method of the profileManager
     behaves as expected and can properly update a profile
     
     Created By: Paul Shamoon
     */
    func testUpdateProfile() -> Void {
        // Store the original state of all profiles
        let originalProfiles = profileManager.profiles
        
        // Store the original state of profile1
        let originalProfile1 = profile1
        
        let updatedDateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -16, to: Date())!

        // Update the profile
        profileManager.updateProfile(
            profile: profile1,
            name: "UpdatedUser1",
            dateOfBirth: updatedDateOfBirth,
            favoriteGenres: ["classical", "folk"],
            hasAgreedToTerms: true,
            userPin: "1234",
            personalSecurityQuestion: "What is this projects name?",
            securityQuestionAnswer: "Moodify"
        )
        
        // Get the updated state of all profiles
        let updatedProfiles = profileManager.profiles
        
        // Get the updated profile1
        let updatedProfile1 = updatedProfiles.first
        
        // Ensure that no new profiles were created
        XCTAssertEqual(originalProfiles.count, updatedProfiles.count)
    
        // Ensure that the original profile does not equal the updated profile
        XCTAssertNotEqual(originalProfile1, updatedProfile1, "The profile did not update properly")
        
        // Make sure that everything we updated persisted
        XCTAssertEqual(updatedProfile1?.name, "UpdatedUser1", "The name did not update properly")
        XCTAssertEqual(updatedProfile1?.favoriteGenres, ["classical", "folk"], "The genres did not update properly")
        XCTAssertEqual(updatedProfile1?.userPin, "1234", "The pin did not update properly")
        XCTAssertEqual(updatedProfile1?.personalSecurityQuestion, "What is this projects name?", "The security question did not update properly")
        XCTAssertEqual(updatedProfile1?.securityQuestionAnswer, "Moodify", "The security question answer did not update properly")
        XCTAssertTrue(
            updatedProfile1?.dateOfBirth != nil &&
            Calendar.current.isDate(updatedDateOfBirth, equalTo: updatedProfile1!.dateOfBirth, toGranularity: .day),
            "The date of birth did not update properly"
        )
    }
    
    
    /*
     Method to test that the deleteProfile method of the profileManager
     behaves as expected and can properly delete a profile
     
     Created By: Paul Shamoon
     */
    func testDeleteProfile() -> Void {
        profileManager.currentProfile = profile1
        
        // Store the original state of all profiles
        let originalProfiles = profileManager.profiles
        
        // Delete profile1
        profileManager.deleteProfile(profile: profile1)
        
        // Get the updated state of all profiles
        let updatedProfiles = profileManager.profiles
        
        // Ensure the size of originalProfiles has changed
        XCTAssertNotEqual(originalProfiles.count, updatedProfiles.count, "The old and new state of profiles should not be equal")
        
        // Ensure profile1 no longer exists in the updated profiles
        XCTAssertFalse(updatedProfiles.contains(where: { $0.id == profile1.id }), "Profile1 should no longer exist in the profiles.")
        
        // Ensure currentProfile is now nil
        XCTAssertNil(profileManager.currentProfile)
    }
    
    
    /*
     Method to test that the deletePin method of the profileManager
     behaves as expected and can properly delete a profiles pin
     
     Created By: Paul Shamoon
     */
    func testDeletePin() -> Void {
        profile1.userPin = "1234"
        
        // Delete the pin for profile1
        profileManager.deletePin(profile: profile1)
        
        // Get the updated state of profile1
        let updatedProfile1 = profileManager.profiles.first( where: { $0.id == profile1.id })
        
        // Ensure that profile1's pin was deleted
        XCTAssertEqual(updatedProfile1?.userPin!, "", "Profile1's pin was not deleted")
    }
    
    
    /*
     Method to test that the verifyPin method of the profileManager behaves as
     expected and can properly verify if the passed in pin matches the profiles pin
     
     Created By: Paul Shamoon
     */
    func testVerifyPin() -> Void {
        profile1.userPin = "1234"
        
        // Ensure that method returns false when pin is incorrect
        XCTAssertFalse(profileManager.verifyPin(for: profile1, enteredPin: "4321"), "Pins  matched")
        
        // Ensure that method returns true when pin is correct
        XCTAssertTrue(profileManager.verifyPin(for: profile1, enteredPin: "1234"), "Pins did not match")
    }
}

