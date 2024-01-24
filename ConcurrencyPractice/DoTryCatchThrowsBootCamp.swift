//
//  DoTryCatchThrowsBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/01/2024.
//

import SwiftUI
import Observation

class DoTryCatchThrowsBootCampManager {
    let isActive: Bool = true
    
    // if isActive true then text changes else error shows
    // OLD Way
    func getTitle1() -> (title: String?, error: Error?) {
        if isActive {
            return ("TEXT CHANGED", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    // if isActive true then success else failure
    // Also OLD Way
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("TEXT CHANGED!!!!!")
        } else {
            return .failure(URLError(.cancelled))
        }
    }
    // if isActive true then doesnt throw an error else throws
    // NEW WAY
    func getTitle3() throws -> String {
        // throws shows that if throws an error and this time we dont say return error but we say ""throw error""
        if isActive {
            return "NEW WAY TEXT!!!"
        } else {
            throw URLError(.badURL)
        }
    }
}

@Observable
class DoTryCatchThrowsBootCampViewModel {
    var text: String = "Starting Text."
    let manager = DoTryCatchThrowsBootCampManager() // Singleton but USE DEPENDENCY INJECTION FOR THIS.
    
    // Methods to fetch Title from manager
    func fetchTitle1() {
        let getTitle = manager.getTitle1()
        
        if let title = getTitle.title {
            self.text = title
        } else if let error = getTitle.error {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle2() {
        let getTitle = manager.getTitle2()
        
        switch getTitle {
        case .success(let success):
            self.text = success
        case .failure(let failure):
            self.text = failure.localizedDescription
        }
    }
    
    func fetchTitle3() {
        do {
            let getTitle = try manager.getTitle3()
            self.text = getTitle
        } catch let error {
            self.text = error.localizedDescription
        }
    }
}

struct DoTryCatchThrowsBootCamp: View {
    var viewModel = DoTryCatchThrowsBootCampViewModel() // Creating VM instance
    
    var body: some View {
        VStack {
            Text(viewModel.text)
                .padding()
                .font(.title3)
                .bold()
                .frame(width: 300, height: 300, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 18.0).fill(.cyan.gradient))
                .onTapGesture {
                    viewModel.fetchTitle3()
                }
        }
        .padding()
    }
}

#Preview {
    DoTryCatchThrowsBootCamp()
}
