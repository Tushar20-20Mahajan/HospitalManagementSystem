import SwiftUI

struct AdminTabBar: View {
    var user: User

    var body: some View {
        TabView {
            AdminHomeView(userType: "Admin", user: user)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Text("Doctors")
                .tabItem {
                    Label("Doctors", systemImage: "person.badge.clock")
                }
            Text("Patients")
                .tabItem {
                    Label("Patients", systemImage: "person.2.fill")
                }
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}



