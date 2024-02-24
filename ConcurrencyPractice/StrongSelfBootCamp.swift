//
//  StrongSelfBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/02/2024.
//

import SwiftUI

final class StrongSelfDataService {
    func getData() async -> String {
        "Updated data!"
    }
}

final class StrongSelfBootCampViewModel: ObservableObject {
    
    @Published var data: String = "Some title!"
    let dataService = StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil // For one task
    private var myTasks: [Task<Void, Never>] = [] // For multiple tasks

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach({ $0.cancel() })
        myTasks = []
    }
    
    // This implies a strong reference...
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This is a strong reference...
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a strong reference...
    func updateData3() {
        Task { [self] in
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    // WE DONT manage these reference as in async await we work at task level so we can cancel them.
    
    // We don't need to manage weak/strong
    // We can manage the Task!
    func updateData5() {
        someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // We can manage the Task!
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task2)
    }
    
    // We purposely do not cancel tasks to keep strong references
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        Task.detached { // This detaches meaning, it is no longer part and will not be cancelled
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData8() async {
        self.data = await self.dataService.getData()
    }

}

struct StrongSelfBootCamp: View {
    
    @StateObject private var viewModel = StrongSelfBootCampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
        // .task auto cancels the task, but if we user .onAppear { Task {} } then we have to manuallay cancel the task overseleves as we do in above .onDisappear
    }
}

#Preview {
    StrongSelfBootCamp()
}
