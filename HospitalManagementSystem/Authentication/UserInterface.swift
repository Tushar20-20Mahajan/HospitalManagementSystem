import SwiftUI

struct HomeView: View {
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
            
            if userType == "Admin" {
                AdminView()
            } else if userType == "Doctor" {
                DoctorView()
            } else if userType == "Patient" {
                PatientView()
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

struct AdminView: View {
    var body: some View {
        Text("Admin Interface")
    }
}

struct DoctorView: View {
    var body: some View {
        Text("Doctor Interface")
    }
}

struct PatientView: View {
    var body: some View {
        Text("Patient Interface")
    }
}

