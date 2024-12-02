//
//  onBoardingViewModel.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/18/24.
//

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var showMoodView = false
    
    let pages: [OnboardingPage]
    private let onCompletion: (() -> Void)?
    
    init(onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
        self.pages = [
            OnboardingPage(title: "Welcome", description: "...", imageName: "..."),
            OnboardingPage(title: "Features", description: "...", imageName: "..."),
            OnboardingPage(title: "Get Started", description: "...", imageName: "...")
        ]
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            showMoodView = true
            onCompletion?()
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}
