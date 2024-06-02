import SwiftUI

struct AdminTabBar: View {
    var user: User

    var body: some View {
        TabView {
            AdminHomeView(userType: "Admin", user: user)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            AdminCategoriesList(userType: "Admin", user: user)
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


