import SwiftUI

@main
struct HospitalApp: App {
    @StateObject private var dataModel = DataModel()
    
    var body: some Scene {
        WindowGroup {
            SignInView()
                .environmentObject(dataModel)
        }
    }
}
