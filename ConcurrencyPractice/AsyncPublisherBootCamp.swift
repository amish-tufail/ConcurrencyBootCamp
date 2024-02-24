//
//  AsyncPublisherBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/02/2024.
//

import SwiftUI

import Combine

// ASYNCPUBLISHER: It is an extension to Publisher, which converts it into an async publisher

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = [] // Now this is combine publisher, in order to use its data, in VM we use combine, to subscribe and fetch that data, but we want to convert it into async
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
    
}

class AsyncPublisherBootCampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
//            .values convert the publisher into async and we then stream this data into our app, values are return in loop format, that is why we are using it in it, THIS IS Async Publisher
            // NEW WAY
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    // Here the fetched data is put into the dataArray which we use in our app, so overall, we have @Published var, we use .values to listen to its Publishes that are happening every 2 second (Like it is publishing changes to its subscribers, here using async publisher we are doing similar subscribing thing we do in combine but now in async await context), then the values we get, we store them and stream into our app and then use it
                    self.dataArray = value
                })
            }
        }
        // OLD WAY
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootCamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootCampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}


#Preview {
    AsyncPublisherBootCamp()
}
