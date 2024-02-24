//
//  SendableBootCamp.swift
//  ConcurrencyPractice
//
//  Created by Amish Tufail on 24/02/2024.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: String) {
        
    }
    
    func updateDatabase(userInfo: MyUserInfo) {
        
    }
    
    func updateDatabase(userInfo: MyClassUserInfo2) {
        
    }
    
}
// SENDABLE: It basically means, it make the sure the passing object is thread safe to work in a concurrent env. Means, that the passing is sendable, it is thread safe and will work perfectly in a concurrecny env. Its just a protocal that you conform to, nothing else.

struct MyUserInfo: Sendable { // Struct are by default thread safe, so we can use sendable protocol
    var name: String
}

// Classes are not thread safe, to conform to sendable protocal all the properties must by let(constants) and it should be a final class. But having immutable class is not realistic, so we make it mutable and then overselves make it thread safe, see Class two for example

final class MyClassUserInfo1:  Sendable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

// @unchecked tells complier not to check it, we will check it ourselves that if it is sendable or not.
// so, we make private properties and make them change using functions and then use queue when changing them.
final class MyClassUserInfo2: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootCampViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info1 = "NEW INFO"
        let info2 = MyActor(title: "info")
        let info3 = MyClassUserInfo2(name: "info")
        
        await manager.updateDatabase(userInfo: info1)
    }
    
}

struct SendableBootCamp: View {
    
    @StateObject private var viewModel = SendableBootCampViewModel()
    
    var body: some View {
        Text("Hello, World!")
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

#Preview {
    SendableBootCamp()
}
