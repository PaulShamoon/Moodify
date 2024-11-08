struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingMoodView(onCompletion: {
                hasCompletedOnboarding = true
            })
        } else {
            // Your main app view here
            MainAppView()
        }
    }
} 