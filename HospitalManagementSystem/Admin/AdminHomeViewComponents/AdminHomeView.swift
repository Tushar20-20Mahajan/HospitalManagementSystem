import SwiftUI

struct AdminHomeView: View {
    var userType: String
    var user: User

    @EnvironmentObject var dataModel: DataModel
    @State private var showingConfirmation = false
    @State private var confirmationType: ConfirmationType = .approve
    @State private var selectedDoctor: Doctor?
    @State var searchText: String = ""

    var filteredDoctors: [Doctor] {
        if dataModel.searchText.isEmpty {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital
        } else {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.filter {
                $0.user.firstName.localizedCaseInsensitiveContains(dataModel.searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(dataModel.searchText)
            }
        }
    }

    enum ConfirmationType {
        case approve
        case reject
    }

    func handleDoctorAction(_ doctor: Doctor, action: ConfirmationType) {
        switch action {
        case .approve:
            dataModel.approveDoctor(doctor)
        case .reject:
            dataModel.rejectDoctor(doctor)
        }
        dataModel.saveSpecialtyDoctors(for: doctor.specialty)
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
                                        confirmationType = .approve
                                        showingConfirmation = true
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

                                    Button(action: {
                                        selectedDoctor = doctor
                                        confirmationType = .reject
                                        showingConfirmation = true
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
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Admin Home")
            .searchable(text: $dataModel.searchText)
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text(confirmationType == .approve ? "Approve Doctor" : "Reject Doctor"),
                    message: Text("Are you sure you want to \(confirmationType == .approve ? "approve" : "reject") this doctor?"),
                    primaryButton: .destructive(Text(confirmationType == .approve ? "Approve" : "Reject")) {
                        if let doctor = selectedDoctor {
                            handleDoctorAction(doctor, action: confirmationType)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeView(userType: "Admin", user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678", firstName: "Admin", lastName: "User", age: 40, gender: "Other", address: "Admin Address"))
            .environmentObject(DataModel())
    }
}
