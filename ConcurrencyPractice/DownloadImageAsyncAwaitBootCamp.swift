//
//  DownloadImageAsyncAwaitBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/01/2024.
//

import SwiftUI
import Observation

class DownloadImageAsyncAwaitBootCampManager {
    let url = URL(string: "https://picsum.photos/200")!
    
    // OLD Method
    // Using escaping
    func downloadImage(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()){
        // We fetch data , create image and return
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let image = UIImage(data: data),
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(image, nil)
        }
        .resume()
    }
    
    // New Method
    // Using Async await
    func downloadImage2() async throws -> UIImage? { // Tells function is async and throws error if exists
        do {
            // We fetch data
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil) // Async function -> .data() so await is must
            guard
                // create image and return
                let image = UIImage(data: data),
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                return nil
            }
            return image
        } catch {
            throw error
        }
    }
}

@Observable
class DownloadImageAsyncAwaitBootCampViewModel {
    var image: UIImage? = nil
    let manager = DownloadImageAsyncAwaitBootCampManager() // Singleton, but use dependency injection
    
    func fetchImage() {
        manager.downloadImage { [weak self] image, error in // call downloadImage function
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchImage2() async { // As calling function -> downloadImage2() is async so this has to be marked as async as well else we cannot call it
        do {
            let image = try await manager.downloadImage2()
//            DispatchQueue.main.async { // We can use this but as it is async function so we should use MainActor
//                self.image = image
//            }
            await MainActor.run { // Puts on main thread as UI change is taking place
                self.image = image
            }
        } catch {
            print(error)
        }
    }
}

struct DownloadImageAsyncAwaitBootCamp: View {
    var viewModel = DownloadImageAsyncAwaitBootCampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250.0, height: 250.0)
            }
        }
        .onAppear {
//            viewModel.fetchImage() // for normal calling
        }
        .onAppear {
            Task { // Cannot call async function in view without using this Task closure
                await viewModel.fetchImage2() // function is async so when calling, await is must.
            }
        }
    }
}

#Preview {
    DownloadImageAsyncAwaitBootCamp()
}
