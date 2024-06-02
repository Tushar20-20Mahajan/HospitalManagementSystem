import SwiftUI

struct PatientTabBar: View {
    var user: User

    var body: some View {
        TabView {
            PatientHomeView(userType: "Patient", user: user)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            PatientCategoriesList(userType: "Patient", user: user)
                .tabItem {
                    Label("Categories", systemImage: "person.badge.clock")
                }
            Text("Laboratory")
                .tabItem {
                    Label("Laboratory", systemImage: "person.2.fill")
                }
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

