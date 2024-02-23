//
//  ActorsBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 23/02/2024.
//

import SwiftUI

class MyDataManager1 {
    
    static let instance = MyDataManager1()
    private init() { }
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
}

class MyDataManager2 {
    
    static let instance = MyDataManager2()
    private init() { }
    
    var data: [String] = []
    // This is a queue created with a unique label
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        // Here when a thread access it, it enters the queu and wait for its turn and then the code executes, and as we are in a async await env, so to get out we had to use completion handler
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    // Non-isolated means that when we access this we dont need to await to get into actor to access it, we can access it directly, they can my propetries as well as functions
    // Normally by default they are Isolated
    nonisolated let myRandomText = "asdfasdfadfsfdsdfs"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
    
}


struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
                .onAppear(perform: {
//                    let newString = manager.myRandomText // Cannot access as async context is needed (Task)
                    let newString2 = manager.myRandomText // Can access now as no longer in async context
                    Task {
//                        let newString =  await manager.getSavedData() // Has to be marked with await as in async context
                        let newString =  manager.getSavedData() // No longer in async context and no await needed
                    }
                })
        .onReceive(timer) { _ in
            // Now what Happens in this case is that, two different threads are accessing the same data, that is MyDataManager1, so this causes data race and even crashing.
//            DispatchQueue.global(qos: .background).async {
//                if let data = await manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }
            
            // Now fix was to introduce queue in Manager, and use that queue, in which threads enters the queue and wait for its turn, this solves the problem of Data Race and Even Crashing
            
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            // Above one was an old way of dealing with the issue, in this we use actors, and they do that queueing thing by default, in this we await to get into actor.
            
                        Task {
                            if let data = await manager.getRandomData() {
                                await MainActor.run(body: {
                                    self.text = data
                                })
                            }
                        }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            // Now what Happens in this case is that, two different threads are accessing the same data, that is MyDataManager1, so this causes data race and even crashing.
            
//            DispatchQueue.global(qos: .default).async {
//                if let data = await manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }
            
            // Now fix was to introduce queue in Manager, and use that queue, in which threads enters the queue and wait for its turn, this solves the problem of Data Race and Even Crashing
            
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            // Above one was an old way of dealing with the issue, in this we use actors, and they do that queueing thing by default, in this we await to get into actor.
            
                        Task {
                            if let data = await manager.getRandomData() {
                                await MainActor.run(body: {
                                    self.text = data
                                })
                            }
                        }
        }
    }
}

struct ActorsBootCamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorsBootCamp()
}
