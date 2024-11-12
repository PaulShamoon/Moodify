struct ContentView: View {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        if showOnboarding {
            OnboardingMoodView(onCompletion: {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                showOnboarding = false
            })
        } else {
            // Your main app content
            MainAppView()
        }
    }
} 