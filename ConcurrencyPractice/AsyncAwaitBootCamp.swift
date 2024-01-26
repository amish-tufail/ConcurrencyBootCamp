//
//  AsyncAwaitBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 26/01/2024.
//

import SwiftUI
import Observation

@Observable
class AsyncAwaitBootCampViewModel {
    var dataArray: [String] = []
    
    func addData1() {
        let title = "Title 1: \(Thread.current)" // Main Thread
        self.dataArray.append(title)
    }
    
    func addData2() {
        DispatchQueue.global().async {
            let title = "Title 2: \(Thread.current)" // Background Thread
//            self.dataArray.append(title) // Bad approach to do UI changes in background thread
            DispatchQueue.main.async {
                self.dataArray.append(title)
                let title = "Title 3: \(Thread.current)" // Now here Main thread
                self.dataArray.append(title)
            }
        }
    }
    
    func addSomething1() async {
        
        let something = "Something 1: \(Thread.current.isMainThread)" // Not Background Thread
        await MainActor.run { // We get into Main Thread
            self.dataArray.append(something)
        }
        // 2 billion nanosecond = 2 second
        try? await Task.sleep(nanoseconds: 2_000_000_000) // so after this sleep/await we dont know which thread task will be it could be main or backgrond so, best is to use MainActor to go into Main thread to update the UI
        
        let something2 = "Something 2: \(Thread.current.isMainThread)" // See Background thread it is
        await MainActor.run {
            self.dataArray.append(something2)
            let something3 = "Something 3: \(Thread.current.isMainThread)" // Here it is Main thread
            self.dataArray.append(something3)
        }
    }
}

struct AsyncAwaitBootCamp: View {
    var viewModel = AsyncAwaitBootCampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            viewModel.addData1()
            viewModel.addData2()
            Task {
                // so await means, that first this addSomething will execute and then the next and next, but there are ways to exceute others as well
                await viewModel.addSomething1()
                // Function 2
                // Function 3
            }
        }
    }
}

#Preview {
    AsyncAwaitBootCamp()
}
