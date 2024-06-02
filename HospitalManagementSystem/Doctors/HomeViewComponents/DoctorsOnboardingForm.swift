import SwiftUI
import PhotosUI

struct DoctorOnboardingForm: View {
    var userType: String
    var user: User
    @Environment(\.presentationMode) var presentationMode
    @State private var specialization: String = "Select Specialization"
    @State private var medicalRegNumber: String = ""
    @State private var consultationFees: String = ""
    @State private var degree: String = ""
    @State private var previousPositions: String = ""
    @State private var biography: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    @State private var showAlert = false
    @State private var emptyFields: [String] = []
    @State private var profilePicture: Data? = nil
    @State private var selectedProfilePicture: PhotosPickerItem? = nil
    @ObservedObject var dataModel: DataModel
    @State private var submitButtonCount: Int = 0
    @State private var isLoading = false

    @State private var showingDocumentPicker = false
    @State private var showingProfilePicturePicker = false

    func validateAndSaveDoctorInformation() {
        emptyFields.removeAll()

        if specialization == "Select Specialization" { emptyFields.append("Specialization") }
        if medicalRegNumber.isEmpty { emptyFields.append("Medical Registration Number") }
        if consultationFees.isEmpty { emptyFields.append("Consultation Fees") }
        if degree.isEmpty { emptyFields.append("Degree") }
        if previousPositions.isEmpty { emptyFields.append("Previous Positions") }
        if biography.isEmpty { emptyFields.append("Biography") }

        if !emptyFields.isEmpty {
            showAlert = true
        } else {
            saveDoctorInformation()
        }
    }

    private func saveDoctorInformation() {
        var doctor = self.dataModel.doctors[self.user] ?? Doctor(user: self.user, specialty: self.specialization, medicalRegNumber: "", consultationFees: "", degree: "", previousPositions: "", biography: "", profilePicture: nil, documents: [], submitButtonCount: 0)
        doctor.specialty = self.specialization
        doctor.medicalRegNumber = self.medicalRegNumber
        doctor.consultationFees = self.consultationFees
        doctor.degree = self.degree
        doctor.previousPositions = self.previousPositions
        doctor.biography = self.biography
        doctor.profilePicture = self.profilePicture
        doctor.documents = self.selectedPhotosData
        doctor.submitButtonCount = 1
        
        self.dataModel.updateDoctor(for: self.user, with: doctor) // Updated line
        
        self.dataModel.doctorsForApprovalAndInTheDataBaseOfHospital.append(doctor)
        
        self.isLoading = true
        self.dataModel.saveDoctorsToFile()
        self.dataModel.saveDoctorsForApprovalToFile()
        self.isLoading = false
        self.presentationMode.wrappedValue.dismiss()
        
        print("Total Updated Doctors -: \(dataModel.doctors)")
        print("Total Updated Doctors For Approval -: \(dataModel.doctorsForApprovalAndInTheDataBaseOfHospital)")
        print("Updated Details -: \(doctor)")

        
        
    }



    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    profilePictureSection
                    aboutSection
                    professionalDetailsSection
                    qualificationsSection
                    professionalExperienceSection
                    documentUploadSection
                }
                .padding()
                .navigationTitle("Fill Information")
                .navigationBarItems(trailing: submitButton)
                .onTapGesture {
                    hideKeyboard()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Incomplete Form"),
                        message: Text("Please fill all required fields: \(emptyFields.joined(separator: ", "))"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPickerView(selectedDataArray: $selectedPhotosData)
            }
            .sheet(isPresented: $showingProfilePicturePicker) {
                ProfilePicturePickerView(selectedData: $profilePicture)
            }
        }
        .onAppear {
            if let doctor = dataModel.doctors[user] {
                specialization = doctor.specialty
                medicalRegNumber = doctor.medicalRegNumber
                consultationFees = doctor.consultationFees
                degree = doctor.degree
                previousPositions = doctor.previousPositions
                biography = doctor.biography
                profilePicture = doctor.profilePicture
                selectedPhotosData = doctor.documents
                submitButtonCount = doctor.submitButtonCount
                
                print("Initial Details -: \(doctor)")
                print("Total Doctors -: \(dataModel.doctors)")
                print("Total Doctors For Approval -: \(dataModel.doctorsForApprovalAndInTheDataBaseOfHospital)")
            }
        }
    }

    private var profilePictureSection: some View {
        Section(header: Text("Profile Picture").font(.headline).padding(.bottom, 5)) {
            VStack {
                if let profilePicture = profilePicture, let uiImage = UIImage(data: profilePicture) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                }

                Button(action: {
                    showingProfilePicturePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Upload Profile Picture")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var aboutSection: some View {
        Section(header: Text("About").font(.headline).padding(.bottom, 5)) {
            FormRowView(icon: "graduationcap.fill", placeholder: "Biography", text: $biography, keyboardType: .default, isHighlighted: emptyFields.contains("Biography"))
        }
    }

    private var professionalDetailsSection: some View {
        Section(header: Text("Professional Details").font(.headline).padding(.bottom, 5)) {
            Group {
                Picker("Specialization", selection: $specialization) {
                    Text("Select Specialization").tag("Select Specialization")
                    ForEach(dataModel.specialties, id: \.id) { specialty in
                        Text(specialty.name).tag(specialty.name)
                    }
                }
                .padding(.horizontal)

                FormRowView(icon: "number.circle.fill", placeholder: "Medical Registration Number", text: $medicalRegNumber, keyboardType: .numbersAndPunctuation, isHighlighted: emptyFields.contains("Medical Registration Number"))

                FormRowView(icon: "dollarsign.circle.fill", placeholder: "Consultation Fees", text: $consultationFees, keyboardType: .decimalPad, isHighlighted: emptyFields.contains("Consultation Fees"))
            }
        }
    }

    private var qualificationsSection: some View {
        Section(header: Text("Qualifications").font(.headline).padding(.bottom, 5)) {
            FormRowView(icon: "graduationcap.fill", placeholder: "Qualification", text: $degree, keyboardType: .default, isHighlighted: emptyFields.contains("Degree"))
        }
    }

    private var professionalExperienceSection: some View {
        Section(header: Text("Professional Experience").font(.headline).padding(.bottom, 5)) {
            FormRowView(icon: "briefcase.fill", placeholder: "Experience", text: $previousPositions, keyboardType: .default, isHighlighted: emptyFields.contains("Previous Positions"))
        }
    }

    private var documentUploadSection: some View {
        Section(header: Text("Document Upload").font(.headline).padding(.bottom, 5)) {
            VStack {
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    HStack {
                        Image(systemName: "doc.fill.badge.plus")
                        Text("Select Documents")
                    }
                }

                if !selectedPhotosData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<selectedPhotosData.count, id: \.self) { index in
                                VStack {
                                    if let uiImage = UIImage(data: selectedPhotosData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                    }

                                    Button(action: {
                                        selectedPhotosData.remove(at: index)
                                    }) {
                                        Text("Remove")
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(width: 100)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: 120) // Adjust height as needed
                }
            }
        }
    }

    private var submitButton: some View {
        HStack {
            if isLoading {
                ProgressView()
            } else {
                Button("Submit") {
                    validateAndSaveDoctorInformation()
                }
            }
        }
    }
}

struct FormRowView: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    var isHighlighted: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(.none)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isHighlighted ? Color.red : Color.clear, lineWidth: 1)
        )
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedDataArray: [Data]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedDataArray = urls.compactMap { try? Data(contentsOf: $0) }
        }
    }
}

struct ProfilePicturePickerView: UIViewControllerRepresentable {
    @Binding var selectedData: Data?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ProfilePicturePickerView

        init(_ parent: ProfilePicturePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedData = nil
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self, let image = image as? UIImage else { return }
                    self.parent.selectedData = image.jpegData(compressionQuality: 1.0)
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
