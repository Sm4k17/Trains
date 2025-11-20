//
//  ContentView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 17.11.2025.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            testFetchStations()
        }
    }
}

// Функция для тестового вызова API
func testFetchStations() {
    // Создаём Task для выполнения асинхронного кода
    Task {
        do {
            // 1. Создаём экземпляр сгенерированного клиента
            let client = Client(
                // Используем URL сервера, также сгенерированный из openapi.yaml (если он там определён)
                serverURL: try Servers.Server1.url(),
                // Указываем, какой транспорт использовать для отправки запросов
                transport: URLSessionTransport()
            )
            
            // 2. Создаём экземпляр нашего сервиса, передавая ему клиент и API-ключ
            let service = NearestStationsService(
                client: client,
                apikey: "a63c3bd4-fd50-47a4-a56b-def74416d733" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
            )
            
            // 3. Вызываем метод сервиса
            print("Fetching stations...")
            let stations = try await service.getNearestStations(
                lat: 59.864177, // Пример координат
                lng: 30.319163, // Пример координат
                distance: 50    // Пример дистанции
            )
            
            // 4. Если всё успешно, печатаем результат в консоль
            print("Successfully fetched stations: \(stations)")
        } catch {
            // 5. Если произошла ошибка на любом из этапов (создание клиента, вызов сервиса, обработка ответа),
            //    она будет поймана здесь, и мы выведем её в консоль
            print("Error fetching stations: \(error)")
            // В реальном приложении здесь должна быть логика обработки ошибок (показ алерта и т. д.)
        }
    }
}

#Preview {
    ContentView()
}
