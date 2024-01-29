//
//  AsyncLetBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 29/01/2024.
//

import SwiftUI

struct AsyncLetBootCamp: View {
    @State var images: [UIImage] = []
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    }
                })
            }
            .navigationTitle("Async Let 😏")
            .onAppear {
                // Now images here load one by one so, how to load them at once, do the second task thing
//                let task1 = Task {
//                    let image1 = try await downloadImage()
//                    self.images.append(image1)
//                    
//                    let image2 = try await downloadImage()
//                    self.images.append(image2)
//                    
//                    let image3 = try await downloadImage()
//                    self.images.append(image3)
//                    
//                    let image4 = try await downloadImage()
//                    self.images.append(image4)
//                }
                
                // Now what is happening here is all images appear at once, but HOW?
                // 1. async let executes all at once
                // 2. then we combine and await on all of them, like till the last is not executed, once its done we get images and then append so, they all appear at once
                // NOTE: It is good only for few task, but multiple tasks we use TaskGroup
                let task2 = Task {
                    async let fetchimage1 = downloadImage()
                    async let fetchimage2 = downloadImage()
                    async let fetchimage3 = downloadImage()
                    async let fetchimage4 = downloadImage()
                    
                    let (image1, image2, image3, image4) = await (try fetchimage1, try fetchimage2, try fetchimage3, try fetchimage4)
                    self.images.append(contentsOf: [image1, image2, image3, image4])
                }
            }
        }
    }
    
    func downloadImage() async throws -> UIImage {
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

#Preview {
    AsyncLetBootCamp()
}
