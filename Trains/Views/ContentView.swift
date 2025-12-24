//
//  ContentView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 17.11.2025.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    // Получаем доступ к глобальному состоянию через Environment
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "train.side.front.car")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: 50))
            
            Text("Яндекс Расписания")
                .font(.title2)
            
            if appState.isLoading {
                ProgressView("Загрузка...")
            } else {
                Button("Запустить тесты") {
                    Task {
                        await runTests()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            // Запускаем проверку при появлении экрана
            await runTests()
        }
    }
    
    // Вспомогательная функция для запуска тестов через AppState
    private func runTests() async {
        await appState.executeWithRetry {
            // Теперь вызываем функцию, которая пробрасывает ошибки
            try await testAllServices()
        }
    }
}

// MARK: - API Testing Logic

// Добавлено 'throws', чтобы ошибки пробрасывались в executeWithRetry
func testAllServices() async throws {
    // Убран внутренний блок do-catch, чтобы ошибки уходили наверх
    let client = Client(
        serverURL: try Servers.Server1.url(),
        transport: URLSessionTransport()
    )
    
    let apikey = "a63c3bd4-fd50-47a4-a56b-def74416d733"
    
    // 1. Тест Copyright
    let copyrightService = CopyrightService(client: client, apikey: apikey)
    let copyright = try await copyrightService.getCopyright()
    print("📄 Copyright: \(copyright.copyright?.text ?? "нет данных")")
    
    // 2. Тест Nearest Stations
    let stationsService = NearestStationsService(client: client, apikey: apikey)
    let stations = try await stationsService.getNearestStations(
        lat: 55.7558, lng: 37.6173, distance: 5
    )
    print("📍 Ближайшие станции: \(stations.stations?.count ?? 0) шт")
    
    // 3. Тест Search
    let searchService = SearchService(client: client, apikey: apikey)
    let searchResult = try await searchService.search(
        from: "s9600213",
        to: "s9600366"
    )
    print("🔍 Поиск: \(searchResult.segments?.count ?? 0) маршрутов")
    
    // 4. Тест Schedule
    let scheduleService = ScheduleService(client: client, apikey: apikey)
    let schedule = try await scheduleService.getSchedule(station: "s9600213")
    print("🕒 Расписание: \(schedule.schedule?.count ?? 0) рейсов")
    
    // 5. Тест Nearest Settlement
    let settlementService = NearestSettlementService(client: client, apikey: apikey)
    let settlement = try await settlementService.getNearestSettlement(lat: 55.7558, lng: 37.6173)
    print("🏙️ Ближайший город: \(settlement.title ?? "не определен")")
    
    // 6. Тест Stations List
    let stationsListService = StationsListService(client: client, apikey: apikey)
    _ = try await stationsListService.getStationsList()
    print("📋 Список станций получена")
    
    // 7. Тест Carrier
    let carrierService = CarrierService(client: client, apikey: apikey)
    let carrierResponse = try await carrierService.getCarrier(code: "680")
    if let carrier = carrierResponse.carrier ?? carrierResponse.carriers?.first {
        print("✈️ Перевозчик: \(carrier.title ?? "неизвестен")")
    }
    
    // 8. Тест Thread
    let threadService = ThreadService(client: client, apikey: apikey)
    if let firstSegment = searchResult.segments?.first,
       let threadUid = firstSegment.thread?.uid {
        
        let threadDetails = try await threadService.getThread(uid: threadUid)
        print("🚂 Детали нитки получены: \(threadDetails.uid ?? "")")
    }
    
    print("\n✅ Все API сервисы работают корректно!")
}

#Preview {
    // Используем синглтон вместо создания нового экземпляра
    ContentView()
        .environment(AppState.shared)
}
