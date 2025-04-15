//
//  Debouncer.swift
//  TestDebouncer
//
//  Created by Carl Nash on 15/04/2025.
//
import Foundation

/// Provides "debouncing" functionality; ie delay a function call until a certain amount of time has passed without being called again.
/// Making this an `actor` gives:
/// - Safe access to `currentTask` even when debouncing from multiple sources - achieved by actor isolation
/// - Built-in serialization of async calls to `debounce(...)`
/// - Cleaner code — you don’t need to DispatchQueue.sync or lock manually
/// Note this means all public APIs must be called using `await`.
actor Debouncer {
    private let delay: TimeInterval
    private var currentTask: Task<Void, Never>?

    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    /// Debounce a function call.
    /// - Parameters:
    ///   - overrideDelay: Allow overriding the default delay
    ///   - operation: The function to be called once the debounce delay time has passed
    func debounce(overrideDelay: TimeInterval? = nil, operation: @escaping () async -> Void) {
        currentTask?.cancel()
        currentTask = Task {
            try? await Task.sleep(for: .seconds(overrideDelay ?? delay))
            guard !Task.isCancelled else {
                return
            }
            await operation()
        }
    }
}

/// Grand Central Dispatch debouncer.
/// This operates using a DispatchWorkItem on a DispatchQueue.
class DebouncerCGD {
    private var delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private var queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func debounce(overrideDelay: TimeInterval? = nil, _ operation: @escaping () -> Void) {
        workItem?.cancel()

        workItem = DispatchWorkItem {
            operation()
        }

        if let workItem {
            queue.asyncAfter(deadline: .now() + (overrideDelay ?? delay), execute: workItem)
        }
    }
}
