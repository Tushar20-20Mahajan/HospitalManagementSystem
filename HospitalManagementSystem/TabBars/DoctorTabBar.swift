import SwiftUI

struct DoctorTabBar: View {
    var user: User

    var body: some View {
        TabView {
            DoctorHomeView(userType: "Doctor", user: user)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Text("Doctors")
                .tabItem {
                    Label("Appointments", systemImage: "person.badge.clock")
                }
            Text("Patients")
                .tabItem {
                    Label("PatientsList", systemImage: "person.2.fill")
                }
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}


