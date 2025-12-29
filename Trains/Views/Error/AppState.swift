//
//  AppState.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppState {
    // MARK: - Синглтон
    static let shared = AppState()
    
    // MARK: - Публичные свойства
    var errorState: ErrorState? = nil
    var isLoading: Bool = false
    
    // MARK: - Публичные методы
    
    func showError(_ error: ErrorState) {
        errorState = error
    }
    
    func hideError() {
        errorState = nil
        retryTask?.cancel()
        retryTask = nil
    }
    
    func showErrorAndRetry(
        _ error: ErrorState,
        delay: TimeInterval = 3,
        maxRetries: Int = 3,
        retryAction: @escaping () async throws -> Void
    ) {
        errorState = error
        retryTask = Task { @MainActor in
            await retryWithDelay(
                error,
                delay: delay,
                remainingAttempts: maxRetries,
                retryAction: retryAction
            )
        }
    }
    
    func executeWithRetry(
        title: String = "Повторить",
        maxRetries: Int = 3,
        action: @escaping () async throws -> Void
    ) async {
        // Не запускаем, если уже идет загрузка
        guard !isLoading else { return }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            try await action()
            hideError() // Если успех — скрываем старые ошибки
            
        } catch is CancellationError {
            // Игнорируем ошибки отмены Task
            return
            
        } catch {
            // 1. Преобразуем ошибку в понятное состояние
            let errorState = mapErrorToErrorState(error)
            
            // 2. Показываем UI
            showError(errorState)
            
            // 3. Логируем для отладки
            print("❌ AppState caught error: \(error)")
            
            // 4. Запускаем автоматический повтор (если нужно)
            showErrorAndRetry(errorState, maxRetries: maxRetries) {
                try await action()
            }
        }
    }
    
    // MARK: - Приватные свойства
    
    // Игнорируем это свойство для отслеживания UI, так как это внутренняя логика
    @ObservationIgnored private var retryTask: Task<Void, Never>?
    
    // MARK: - Приватные методы
    
    private func retryWithDelay(
        _ error: ErrorState,
        delay: TimeInterval,
        remainingAttempts: Int,
        retryAction: @escaping () async throws -> Void
    ) async {
        guard remainingAttempts > 0 else { return }
        
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !Task.isCancelled else { return }
        
        do {
            try await retryAction()
            hideError()
            
        } catch let caughtError {
            let errorState = mapErrorToErrorState(caughtError)
            
            await retryWithDelay(
                errorState,
                delay: delay,
                remainingAttempts: remainingAttempts - 1,
                retryAction: retryAction
            )
        }
    }
    
    private func mapErrorToErrorState(_ error: Error) -> ErrorState {
        let nsError = error as NSError
        
        // Проверка на отсутствие связи
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .offline
            case NSURLErrorTimedOut:
                return .custom("Превышено время ожидания")
            default:
                return .server
            }
        }
        
        // Проверка на ошибки API (если пришел текст от сервера)
        let description = error.localizedDescription
        if description.contains("429") {
            return .custom("Лимит запросов исчерпан (429)")
        }
        
        return .custom(description.isEmpty ? "Произошла непредвиденная ошибка" : description)
    }
    
    // MARK: - Инициализация
    
    // Приватный инициализатор для синглтона
    private init() {}
}
