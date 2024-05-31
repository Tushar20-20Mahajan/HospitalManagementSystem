import SwiftUI

struct PatientHomeView: View {
    var userType: String
    var user: User

    var body: some View {
        VStack {
            Text("Welcome, \(user.firstName) \(user.lastName)!")
                .font(.largeTitle)
                .padding()
            
            Text("You are logged in as a \(userType).")
                .font(.title)
                .padding()
            
            Text("Patient Interface")
        }
        .onAppear {
            print("User Type: \(userType)")
            print("User: \(user)")
        }
    }
}


