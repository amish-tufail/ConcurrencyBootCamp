//
//  GlobalActorBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 23/02/2024.
//

import SwiftUI

// Can be struct or class
@globalActor final class MyFirstGlobalActor {
    
    static var shared = MyNewDataManager() // Here singelton instance creation of an Actor is a **MUST**
    
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five", "Six"]
    }
    
}

//@MainActor // This tells that whole class will be on MainActor (Main Thread)
class GlobalActorBootCampViewModel: ObservableObject {
    
   @MainActor // We can mark properties that update UI also MainActor so they are always on Main Thread
    @Published var dataArray: [String] = []
    let manager = MyNewDataManager()
    let manager2 = MyFirstGlobalActor.shared // Always access shared
    
    // Now this function is not part of an actor, we have made it async by writing the keyword, but we can make it isolated to an actor using global actors
    
    func getData() async {
        // HEAVY COMPLEX METHODS
        let data =  await manager.getDataFromDatabase()
        await MainActor.run(body: {
            self.dataArray = data
        })
    }
    
    // Below we made this function isolated to the actor, meaning this function is part of that Actor (MyNewDataManager)
    // Isolated functions are async, so here below as it is isolated it become async
    
    //    nonisolated
     @MyFirstGlobalActor func getData2() {
        // HEAVY COMPLEX METHODS
        Task {
            let data = await manager2.getDataFromDatabase()
            await MainActor.run(body: { // Usually complier doesn't give warning to jump to Main Thread, but as we marked the property as MainActor, so here it forces us to use this
                self.dataArray = data
            })
        }
    }
}


struct GlobalActorBootCamp: View {
    @StateObject private var viewModel = GlobalActorBootCampViewModel()
    
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
            await viewModel.getData2()
        }
    }
    
}

#Preview {
    GlobalActorBootCamp()
}
