import SwiftUI

struct HomeView: View {
    var userType: String
    var user: User
    
    var body: some View {
        VStack {
            
            
            if userType == "Admin" {
                AdminTabBar(user: user)
            } else if userType == "Doctor" {
                DoctorTabBar(user: user)
            } else if userType == "Patient" {
                PatientTabBar(user: user)
            } else {
                Text("Unknown user type")
            }
        }
        .onAppear {
            print("User Type: \(userType)")
            print("User: \(user)")
        }
    }
}


