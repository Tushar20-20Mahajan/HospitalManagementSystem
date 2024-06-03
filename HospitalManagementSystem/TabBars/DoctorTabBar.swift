import SwiftUI

struct DoctorTabBar: View {
    var user: User

    var body: some View {
        TabView {
            DoctorHomeView(userType: "Doctor", user: user)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            DoctorOnboardingForm(userType:  "Doctor", user: user, dataModel: DataModel())
                .tabItem {
                    Label("Appointments", systemImage: "person.badge.clock")
                }
            Text("Patients")
                .tabItem {
                    Label("PatientsList", systemImage: "person.2.fill")
                }
            DoctorProfile(userType: "Doctor", user: user)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}


