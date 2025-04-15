//
//  ContentView.swift
//  TestDebouncer
//
//  Created by Carl Nash on 14/04/2025.
//

import SwiftUI

struct ContentView: View {
    @State var searchText = ""
    @State var searchQuery = ""
    let debouncer = Debouncer(delay: 1)

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    Task {
                        await debouncer.debounce() {
                            searchQuery = newValue
                        }
                    }
                }

            Text("Searching for: \(searchQuery)")

            Spacer()
                .frame(minHeight: 0) // get a warning without this
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
