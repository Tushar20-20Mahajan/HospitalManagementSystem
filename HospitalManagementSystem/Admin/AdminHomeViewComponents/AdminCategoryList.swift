import SwiftUI

struct AdminCategoriesList: View {
    var userType: String
    var user: User

    @EnvironmentObject var dataModel: DataModel

    var body: some View {
        NavigationView {
            List(filteredSpecialties) { specialty in
                NavigationLink(destination: DoctorsListView(specialty: specialty)) {
                    HStack {
                        Image(specialty.imageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading) {
                            Text(specialty.name)
                                .font(.headline)
                            Text(specialty.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Categories")
            .searchable(text: $dataModel.searchText)
        }
    }

    var filteredSpecialties: [Specialty] {
        if dataModel.searchText.isEmpty {
            return dataModel.specialties
        } else {
            return dataModel.specialties.filter { $0.name.localizedCaseInsensitiveContains(dataModel.searchText) || $0.description.localizedCaseInsensitiveContains(dataModel.searchText) }
        }
    }
}

struct DoctorsListView: View {
    var specialty: Specialty

    var body: some View {
        List(specialty.doctors) { doctor in
            HStack {
                Image(uiImage: UIImage(data: doctor.profilePicture ?? Data()) ?? UIImage())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
                VStack(alignment: .leading) {
                    Text("\(doctor.user.firstName) \(doctor.user.lastName)")
                        .font(.headline)
                    Text(doctor.specialty)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
        }
        .navigationTitle(specialty.name)
    }
}

struct CategoriesList_Previews: PreviewProvider {
    static var previews: some View {
        AdminCategoriesList(userType: "Admin", user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678", firstName: "Admin", lastName: "User", age: 40, gender: "Other", address: "Admin Address"))
            .environmentObject(DataModel())
    }
}
