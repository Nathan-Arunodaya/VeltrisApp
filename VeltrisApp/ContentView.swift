import SwiftUI

struct ContentView: View {
    @AppStorage("darkMode") var darkMode: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Screen 1")
                    .font(.largeTitle)
                NavigationLink("Go to Screen 2", destination: SecondView())
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

struct SecondView: View {
    @AppStorage("darkMode") var darkMode: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Screen 2")
                .font(.largeTitle)
            Toggle("Dark Mode", isOn: $darkMode)
                .padding()
        }
    }
}
