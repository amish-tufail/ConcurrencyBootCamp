//
//  TaskBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 29/01/2024.
//

import SwiftUI
import Observation

@Observable
class TaskBootCampViewModel {
    var image1: UIImage? = nil
    var image2: UIImage? = nil
    
    func downloadImage1() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        let url = URL(string: "https://picsum.photos/200")!
        let data = try? await URLSession.shared.data(from: url, delegate: nil)
        await MainActor.run {
            self.image1 = UIImage(data: data!.0)
        }
        print("SUCESS")
    }
    
    func downloadImage2() async {
        let url = URL(string: "https://picsum.photos/200")!
        let data = try? await URLSession.shared.data(from: url, delegate: nil)
        await MainActor.run {
            self.image2 = UIImage(data: data!.0)
        }
        print("SUCESS")
    }
}

struct TaskHomeView: View {
    var body: some View {
        NavigationView(content: {
            NavigationLink(destination: TaskBootCamp()) { Text("CLICK ME") }
        })
    }
}

struct TaskBootCamp: View {
    var viewModel = TaskBootCampViewModel()
    @State private var cancelTask:  Task<(), Never>? = nil
    var body: some View {
        VStack {
            if let image = viewModel.image1 {
                Image(uiImage: image)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
            }
        }
        .task {
            // THIS IS EASIEST, we dont here do manually cancellation, view does it auto, so use this always
            
            // One more thing
            // I have to do this also, try always to check that task is cancelled or not using below modifier
//            try? Task.checkCancellation() // so if cancelled it throws an error to stop the task if it is not
        }
        
        .onDisappear {
            cancelTask?.cancel() // This cancels the task
        }
        .onAppear {
            // So the problem here is that if we come into this view, task start but if we go back it is not cancelled, so we have to manually cancel it for that we use the notation below this task.
//             Task {
//                await viewModel.downloadImage1()
//                await viewModel.downloadImage2()
//            }
            // so we equal it to created @State var and then use in onDisappear
            cancelTask = Task {
               await viewModel.downloadImage1()
               await viewModel.downloadImage2()
           }
            
            // We can give priorities to our threads with High being the highest and background being the lowest
            Task(priority: .high) {
//                Task.yield()  This suspends the current task
            }
        }
    }
}

#Preview {
    TaskBootCamp()
}
