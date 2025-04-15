# TestDebouncer

## Overview
Test app demonstrating "debouncing" functionality using user input and updating the text output.

Debouncing definition:
> Debouncing, in the context of programming, means to discard operations that occur too close together during a specific interval, and consolidate them into a single invocation.

In this case; as the user types, this updates the output text based on the user input, but the text only updates once the user stops typing for x number of seconds.

This would generally be used in something like calling a network API, where the API should only be called once the user has stopped typing for a definied time period, to minimise the amount of network calls performed.

## Debouncer
This is an `actor` object that provides a `debounce()` function.

This object is initialised with a `delay` in seconds (defaults to 1 second), and this is used for all calls to the `debounce` function. If required, this delay can be overridden when calling `debounce`.

The `debounce` function takes a closure that will be called by the function after the time delay has passed.

Calling `debounce` cancels any previous Tasks and initialises a new Task that will call the passed in closure after the specified time delay.

### Protecting Shared Mutable State in Concurrency

As `Debouncer` is an `actor` object, this means that all calls to public APIs are implicitly `async` and must be called using `await`. This is feature of `actor` objects and provides thread safety by isolating access to the object and state.

The `Debouncer` holds a `currentTask`:

```private var currentTask: Task<Void, Never>?```

This property is mutable and shared across multiple calls, possibly coming from different tasks or threads (like user typing rapidly). Without protection, this could result in race conditions when:

* Two calls happen almost at the same time
* One tries to cancel the task while another creates a new one

**By making it an actor, Swift guarantees that:**
* Access to `currentTask` is isolated
* Only one caller at a time can interact with it
* We don't need to manually worry about locks or data races

**What the actor provides:**
* Safe access to `currentTask` even when debouncing from multiple sources
* Built-in serialization of async calls to `debounce`
* Cleaner code — we don’t need to `DispatchQueue.sync` or lock manually

## DebouncerGCD

For comparison, this is a debouncer implemented using Grand Central Dispatch rather than the newer Concurrency code, but the behaviour is the same.

## UI

The app includes a simple view containing a `TextField` view for input and a `Text` view to show output.

Whenever the user edits the text in the input field this calls the `Debouncer.debounce()` function, this function waits for the amount of time configured on the `Debouncer` (default 1 sec) before calling the passed closure.

If the `debounce` function is called before this delay time passes then the previous closure is not called and the function will wait for the delay duration before calling the closure again.

This repeats whenever `debounce` is called until the amount of time between calling the `debounce` function exceeds the `delay` duration of the Debouncer, in which case the `debounce` closure argument is then called.

When the closure is called, this sets the output text value and updates the UI to display this in the `Text` view.
