import SwiftUI

// 1. Shapes that match the JSON we get back
struct WeatherResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature2m: Double
    let windSpeed10m: Double

    // Maps the JSON names (with underscores) to Swift names
    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case windSpeed10m = "wind_speed_10m"
    }
}

// 2. The three situations the screen can be in
enum LoadState {
    case loading
    case loaded(CurrentWeather)
    case failed(String)
}

// 3. The screen itself
struct WeatherView: View {
    @State private var state: LoadState = .loading

    var body: some View {
        VStack(spacing: 16) {
            switch state {
            case .loading:
                ProgressView("Loading weather...")
            case .loaded(let weather):
                Text("\(weather.temperature2m, specifier: "%.1f")°C")
                    .font(.largeTitle)
                Text("Wind: \(weather.windSpeed10m, specifier: "%.1f") km/h")
            case .failed(let message):
                Text(message)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                Button("Try again") {
                    Task { await loadWeather() }
                }
            }
        }
        .padding()
        .navigationTitle("Weather")
        .task { await loadWeather() }
    }

    func loadWeather() async {
        state = .loading

        let address = "https://api.open-meteo.com/v1/forecast?latitude=51.5&longitude=-0.12&current=temperature_2m,wind_speed_10m"
        guard let url = URL(string: address) else {
            state = .failed("Invalid address.")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                state = .failed("The server had a problem. Please try again.")
                return
            }

            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            state = .loaded(decoded.current)
        } catch {
            state = .failed("Couldn't load the weather. Check your connection.")
        }
        }
    }


#Preview {
    NavigationStack { WeatherView() }
}
