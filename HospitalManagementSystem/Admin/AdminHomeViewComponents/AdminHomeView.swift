import SwiftUI

struct AdminHomeView: View {
    var userType: String
    var user: User

    @EnvironmentObject var dataModel: DataModel
    @State private var showingConfirmation = false
    @State private var confirmationType: ConfirmationType = .approve
    @State private var selectedDoctor: Doctor?
    @State private var searchText: String = ""

    var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital
        } else {
            return dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.filter {
                $0.user.firstName.localizedCaseInsensitiveContains(searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(searchText)
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
                    if filteredDoctors.isEmpty {
                        Text("No doctors found.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredDoctors) { doctor in
                            DoctorListItemView(doctor: doctor, onApprove: {
                                selectedDoctor = doctor
                                confirmationType = .approve
                                showingConfirmation = true
                            }, onReject: {
                                selectedDoctor = doctor
                                confirmationType = .reject
                                showingConfirmation = true
                            })
                        }
                    }
                }
            }
            .navigationTitle("Admin Home")
            .searchable(text: $searchText)
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

struct DoctorListItemView: View {
    var doctor: Doctor
    var onApprove: () -> Void
    var onReject: () -> Void

    var body: some View {
        HStack {
            if let profilePictureData = doctor.profilePicture,
               let uiImage = UIImage(data: profilePictureData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text("\(doctor.user.firstName) \(doctor.user.lastName)")
                    .font(.headline)
                    .frame(minWidth: 150)
                    .padding(.bottom, 10)
                Text(doctor.specialty)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                HStack {
                    Button(action: onApprove) {
                        Text("Approve")
                            .padding(.vertical, 3)
                            .padding(.horizontal, 10)
                            .frame(minWidth: 110)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    Button(action: onReject) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeView(userType: "Admin", user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678", firstName: "Admin", lastName: "User", age: 40, gender: "Other", address: "Admin Address"))
            .environmentObject(DataModel())
    }
}
