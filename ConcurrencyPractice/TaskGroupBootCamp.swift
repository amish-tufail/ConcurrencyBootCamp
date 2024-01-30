//
//  TaskGroupBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 29/01/2024.
//

import SwiftUI
import Observation

class TaskGroupBootCampManager {
    
    func downloadWithTaskGroup() async throws -> [UIImage] {
        let urlArray = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
        ]
        
        // Use withThrowingTaskGroup when the function inside throws else use withTaskGroup
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in // Tell return type here
            var images: [UIImage] = []
            images.reserveCapacity(urlArray.count) // Boosts performance
            
            for url in urlArray { // Iterate over it
                group.addTask { // this is child task we adding in main task, Main task called in View as .task {} 
                    try? await self.downloadImage(urlString: url)
                }
            }
            // Now here we iterate over group and get image
            // So in group we have mutliple tasks, then we await on them and get images and then append
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
    
    // Same as before
    func downloadImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

@Observable
class TaskGroupBootCampViewModel {
    var images: [UIImage] = []
    let manager = TaskGroupBootCampManager()
    
    func fetchImage() async {
        if let images = try? await manager.downloadWithTaskGroup() {
            await MainActor.run {
                self.images.append(contentsOf: images)
            }
        }
    }
}

struct TaskGroupBootCamp: View {
    var viewModel = TaskGroupBootCampViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    }
                })
            }
            .navigationTitle("Task Group 😏")
            // MAIN TASK
            .task {
                await viewModel.fetchImage()
            }
        }
        
    }
}

#Preview {
    TaskGroupBootCamp()
}
