//
//  MVVMBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/02/2024.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some Data!"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some Data!"
    }
}

// Most of our Concurrency stuff should be in our viewModel

@MainActor // 4. Way to make this on Main Actor, this makes the whole class and everything in it on Main Actor
final class MVVMBootCampViewModel: ObservableObject {
    
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @MainActor // 3. Way to make this on Main Actor, here only this property is on it, so when we update it then it has to be on Main Actor if is not then it will throw error and we have to do await MainActor.run({})
    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
//    @MainActor // 1. Way to make this on Main Actor, here whole function is on it
    func onCallToActionButtonPressed() {
        let task = Task { @MainActor in // 2. Way to make this on Main Actor, now the task is on it
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootCamp: View {
    
    @StateObject private var viewModel = MVVMBootCampViewModel()
    
    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .onDisappear {
            
        }
    }
}

#Preview {
    MVVMBootCamp()
}
