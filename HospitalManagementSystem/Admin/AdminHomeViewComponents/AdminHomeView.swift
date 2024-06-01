import SwiftUI

struct AdminHomeView: View {
    var userType: String
    var user: User

    @EnvironmentObject var viewModel: DataModel
    @State private var showingApproveConfirmation = false
    @State private var showingRejectConfirmation = false
    @State private var selectedDoctor: Doctor?

    // Search Functionality
    @State private var searchText: String = ""
    
    var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return viewModel.doctorsForApprovalAndInTheDataBaseOfHospital
        } else {
            return viewModel.doctorsForApprovalAndInTheDataBaseOfHospital.filter {
                $0.user.firstName.localizedCaseInsensitiveContains(searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Doctors")) {
                    ForEach(viewModel.doctorsForApprovalAndInTheDataBaseOfHospital) { doctor in
                        DoctorRowView(doctor: doctor,
                                      onApprove: { selectDoctorForApproval(doctor) },
                                      onReject: { selectDoctorForRejection(doctor) })
                    }
                }
            }

            .navigationTitle("Doctors")
            .searchable(text: $searchText)
            .alert(isPresented: $showingApproveConfirmation) {
                Alert(
                    title: Text("Approve Doctor"),
                    message: Text("Are you sure you want to approve this doctor?"),
                    primaryButton: .destructive(Text("Approve")) {
                        if let doctor = selectedDoctor {
                            viewModel.approveDoctor(doctor)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingRejectConfirmation) {
                Alert(
                    title: Text("Reject Doctor"),
                    message: Text("Are you sure you want to reject this doctor?"),
                    primaryButton: .destructive(Text("Reject")) {
                        if let doctor = selectedDoctor {
                            viewModel.rejectDoctor(doctor.user)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                print("User Type: \(userType)")
                print("User: \(user)")
            }
        }
    }
    
    private func selectDoctorForApproval(_ doctor: Doctor) {
        selectedDoctor = doctor
        showingApproveConfirmation = true
    }

    private func selectDoctorForRejection(_ doctor: Doctor) {
        selectedDoctor = doctor
        showingRejectConfirmation = true
    }
}

struct DoctorRowView: View {
    var doctor: Doctor
    var onApprove: () -> Void
    var onReject: () -> Void

    var body: some View {
        HStack {
            ProfilePictureView(imageData: doctor.profilePicture)
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text("\(doctor.user.firstName) \(doctor.user.lastName)")
                    .font(.headline)
                    .padding(.bottom, 10)
                Text(doctor.specialty)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                ActionButtons(onApprove: onApprove, onReject: onReject)
            }
            Spacer()
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
        }
    }
}

struct ProfilePictureView: View {
    var imageData: Data?

    var body: some View {
        Group {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

struct ActionButtons: View {
    var onApprove: () -> Void
    var onReject: () -> Void

    var body: some View {
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
            .padding(.leading, 20)
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeView(userType: "Admin", user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678", firstName: "Admin", lastName: "User", age: 40, gender: "Other", address: "Admin Address"))
            .environmentObject(DataModel())
    }
}
