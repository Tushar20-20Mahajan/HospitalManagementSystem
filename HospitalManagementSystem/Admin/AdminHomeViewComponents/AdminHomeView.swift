import SwiftUI

struct AdminHomeView: View {
    var userType: String
    var user: User

    @EnvironmentObject var dataModel: DataModel
    @State private var showingApproveConfirmation = false
    @State private var showingRejectConfirmation = false
    @State private var selectedDoctor: Doctor?
    @State var searchText: String = ""

    var filteredDoctors: [Doctor] {
        if dataModel.searchText.isEmpty {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital
        } else {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.filter { $0.user.firstName.localizedCaseInsensitiveContains(dataModel.searchText) || $0.specialty.localizedCaseInsensitiveContains(dataModel.searchText) }
        }
    }

    func approveDoctor(_ doctor: Doctor) {
        if let index = dataModel.specialties.firstIndex(where: { $0.name == doctor.specialty }) {
            dataModel.specialties[index].doctors.append(doctor)
        } else {
            if let existingSpecialty = dataModel.specialties.first(where: { $0.name == doctor.specialty }) {
                let newSpecialty = Specialty(imageName: existingSpecialty.imageName, name: existingSpecialty.name, description: existingSpecialty.description, doctors: [doctor])
                dataModel.specialties.append(newSpecialty)
            }
        }
        dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.removeAll { $0.id == doctor.id }
        dataModel.saveDoctorsToFile()
    }

    func rejectDoctor(_ doctor: Doctor) {
        dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.removeAll { $0.id == doctor.id }
        dataModel.saveDoctorsToFile()
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Doctors")) {
                    ForEach(filteredDoctors) { doctor in
                        HStack {
                            Image(uiImage: UIImage(data: doctor.profilePicture ?? Data()) ?? UIImage())
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text("\(doctor.user.firstName) \(doctor.user.lastName)")
                                    .font(.headline)
                                    .frame(minWidth: 150)
                                    .padding(.bottom, 10)
                                Text(doctor.specialty)
                                    .font(.subheadline)
                                    .padding(.bottom, 10)
                                HStack {
                                    Button(action: {
                                        selectedDoctor = doctor
                                        showingApproveConfirmation = true
                                    }) {
                                        Text("Approve")
                                            .padding(.vertical, 3)
                                            .padding(.horizontal, 10)
                                            .frame(minWidth: 110)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .alert(isPresented: $showingApproveConfirmation) {
                                        Alert(
                                            title: Text("Approve Doctor"),
                                            message: Text("Are you sure you want to approve this doctor?"),
                                            primaryButton: .destructive(Text("Approve")) {
                                                if let doctor = selectedDoctor {
                                                    approveDoctor(doctor)
                                                }
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }

                                    Button(action: {
                                        selectedDoctor = doctor
                                        showingRejectConfirmation = true
                                    }) {
                                        Text("Reject")
                                            .padding(.vertical, 3)
                                            .padding(.horizontal, 10)
                                            .frame(minWidth: 110)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .alert(isPresented: $showingRejectConfirmation) {
                                        Alert(
                                            title: Text("Reject Doctor"),
                                            message: Text("Are you sure you want to reject this doctor?"),
                                            primaryButton: .destructive(Text("Reject")) {
                                                if let doctor = selectedDoctor {
                                                    rejectDoctor(doctor)
                                                }
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Admin Home")
            .searchable(text: $dataModel.searchText)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeView(userType: "Admin", user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678", firstName: "Admin", lastName: "User", age: 40, gender: "Other", address: "Admin Address"))
            .environmentObject(DataModel())
    }
}
