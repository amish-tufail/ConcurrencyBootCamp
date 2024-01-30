//
//  ContinuationsBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 30/01/2024.
//

import SwiftUI
import Observation

class ContinuationsBootCampManager {
    let url = URL(string: "https://picsum.photos/200")!
    
    func downloadData1() async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            throw error
        }
    }
    
    // This is how we convert NON-ASYNC function to ASYNC function
    func downloadData2() async throws -> Data {
        
        // What is happening?
        // We come into this function in async context, then we enter "continuation" which is also in async context, then we basically suspend the task and go into non-async context do our work and return using continuation using async
        // NOTE: Contination.resume must be used at least once in our function so we have to see all possible scenarios in here like we seeing here
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
}

@Observable
class ContinuationsBootCampViewModel {
    var image: UIImage? = nil
    let manager = ContinuationsBootCampManager()
    
    func fetchImage1() async {
        if let data = try? await manager.downloadData1() {
            self.image = UIImage(data: data)
        }
    }
    
    func fetchImage2() async {
        if let data = try? await manager.downloadData2() {
            self.image = UIImage(data: data)
        }
    }
}

struct ContinuationsBootCamp: View {
    var viewModel = ContinuationsBootCampViewModel()
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 150.0, height: 150.0)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
        }
        .task {
            await viewModel.fetchImage2()
        }
    }
}

#Preview {
    ContinuationsBootCamp()
}
