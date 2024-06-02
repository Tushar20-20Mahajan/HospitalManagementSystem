    import Foundation
    import SwiftUI

    struct User: Identifiable, Equatable, Hashable, Codable {
        let id: UUID
        let email: String
        let phoneNumber: String
        let password: String
        let firstName: String
        let lastName: String
        let age: Int
        let gender: String
        let address: String

        init(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, age: Int, gender: String, address: String) {
            self.id = UUID()
            self.email = email
            self.phoneNumber = phoneNumber
            self.password = password
            self.firstName = firstName
            self.lastName = lastName
            self.age = age
            self.gender = gender
            self.address = address
        }

        static func == (lhs: User, rhs: User) -> Bool {
            return lhs.email == rhs.email
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(email)
        }
    }

    struct Admin: Codable {
        var user: User
        static let adminEmail = "admin@hospital.com"
        static let adminPhoneNumber = "9876543210"
        static let adminPassword = "12345678"
        static let adminFirstName = "Admin"
        static let adminLastName = "User"
        static let adminAge = 40
        static let adminGender = "Other"
        static let adminAddress = "Admin Address"
    }

    struct Doctor: Codable, Identifiable {
        var id: UUID { user.id }
        var user: User
        var specialty: String
        var medicalRegNumber: String
        var consultationFees: String
        var degree: String
        var previousPositions: String
        var biography: String
        var profilePicture: Data?
        var documents: [Data]
        var submitButtonCount: Int
    }

    struct Patient: Codable {
        var user: User
    }

    struct Specialty: Identifiable, Codable {
        var id = UUID()
        var imageName: String
        var name: String
        var description: String
        var doctors: [Doctor]
    }

    class DataModel: ObservableObject {
        @Published private(set) var admins: [User: Admin] = [:]
        @Published private(set) var doctors: [User: Doctor] = [:]
        @Published private(set) var patients: [User: Patient] = [:]
        @Published var specialties: [Specialty] = []
        @Published var doctorsForApprovalAndInTheDataBaseOfHospital: [Doctor] = []
        @Published var searchText: String = "" 
        
        
        // Method to update doctors dictionary
           func updateDoctor(for user: User, with doctor: Doctor) {
               doctors[user] = doctor
           }

        init() {
            loadAllData()
            initializeAdmins()
        }

        private func initializeAdmins() {
            let adminUser = User(email: Admin.adminEmail, phoneNumber: Admin.adminPhoneNumber, password: Admin.adminPassword, firstName: Admin.adminFirstName, lastName: Admin.adminLastName, age: Admin.adminAge, gender: Admin.adminGender, address: Admin.adminAddress)
            admins = [adminUser: Admin(user: adminUser)]
        }

        func signUpDoctor(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, gender: String, age: Int, address: String, specialty: String, medicalRegNumber: String, consultationFees: String, degree: String, previousPositions: String, biography: String, profilePicture: Data?, documents: [Data], submitButtonCount: Int = 0) {
            guard !doctors.keys.contains(where: { $0.email == email }) else {
                // Handle error: doctor already exists
                return
            }
            let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, age: age, gender: gender, address: address)
            let newDoctor = Doctor(user: newUser, specialty: specialty, medicalRegNumber: medicalRegNumber, consultationFees: consultationFees, degree: degree, previousPositions: previousPositions, biography: biography, profilePicture: profilePicture, documents: documents, submitButtonCount: submitButtonCount)
            doctors[newUser] = newDoctor
            saveDoctorsToFile()
        }

        func signUpPatient(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, age: Int, gender: String, address: String) {
            guard !patients.keys.contains(where: { $0.email == email }) else {
                // Handle error: patient already exists
                return
            }
            let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, age: age, gender: gender, address: address)
            let newPatient = Patient(user: newUser)
            patients[newUser] = newPatient
            savePatientsToFile()
        }

        func signUp(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, userType: String, age: Int? = nil, gender: String = "", address: String = "", specialty: String = "", medicalRegNumber: String = "", consultationFees: String = "", degree: String = "", previousPositions: String = "", biography: String = "", profilePicture: Data? = nil, documents: [Data] = [], submitButtonCount: Int = 0) {
            switch userType {
            case "Doctor":
                if let age = age {
                    signUpDoctor(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, gender: gender, age: age, address: address, specialty: specialty, medicalRegNumber: medicalRegNumber, consultationFees: consultationFees, degree: degree, previousPositions: previousPositions, biography: biography, profilePicture: profilePicture, documents: documents, submitButtonCount: submitButtonCount)
                } else {
                    // Handle error: age is required for doctor
                }
            case "Patient":
                if let age = age {
                    signUpPatient(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, age: age, gender: gender, address: address)
                } else {
                    // Handle error: age is required for patient
                }
            default:
                break
            }
        }

        func approveDoctor(_ doctor: Doctor) {
            if let index = specialties.firstIndex(where: { $0.name == doctor.specialty }) {
                specialties[index].doctors.append(doctor)
            } else {
                let newSpecialty = Specialty(imageName: "", name: doctor.specialty, description: "", doctors: [doctor])
                specialties.append(newSpecialty)
            }
            doctorsForApprovalAndInTheDataBaseOfHospital.removeAll { $0.id == doctor.id }
            saveDoctorsForApprovalToFile()
            saveSpecialtiesToFile()
        }

        func rejectDoctor(_ doctor: User) {
            doctorsForApprovalAndInTheDataBaseOfHospital.removeAll { $0.user.id == doctor.id }
            saveDoctorsForApprovalToFile()
        }

        func signIn(email: String, password: String) -> (String, User?) {
            if let admin = admins.values.first(where: { $0.user.email == email && $0.user.password == password }) {
                return ("Admin", admin.user)
            } else if let doctor = doctors.values.first(where: { $0.user.email == email && $0.user.password == password }) {
                return ("Doctor", doctor.user)
                } else if let patient = patients.values.first(where: { $0.user.email == email && $0.user.password == password }) {
                return ("Patient", patient.user)
                } else {
                return ("None", nil)
                }
                }
        private func loadAllData() {
            self.doctors = DataModel.loadFromFileDoctors() ?? [:]
            self.patients = DataModel.loadFromFilePatients() ?? [:]
            self.doctorsForApprovalAndInTheDataBaseOfHospital = DataModel.loadFromFileDoctorsForApproval() ?? []
            self.specialties = [
                Specialty(imageName: "heart", name: "Cardiologist", description: "Heart and Blood vessels", doctors: []),
                Specialty(imageName: "rash", name: "Dermatology", description: "Skin, hair, and nails.", doctors: []),
                Specialty(imageName: "heel", name: "Anesthesiology", description: "Pain relief", doctors: []),
                Specialty(imageName: "stomach", name: "Gastroenterology", description: "Digestive system disorders", doctors: []),
                Specialty(imageName: "brain", name: "Neurologist", description: "Brain and neurons", doctors: []),
                Specialty(imageName: "uterus", name: "Gynecologist", description: "Female reproductive system", doctors: []),
                Specialty(imageName: "Ortho", name: "Orthopedic", description: "Bones and joints", doctors: []),
                Specialty(imageName: "Teeth", name: "Dentist", description: "Teeth and oral health", doctors: []),
                Specialty(imageName: "Phisio", name: "Physiotherapist", description: "Physical therapy", doctors: [])
            ]
        }

        static func loadFromFileDoctors() -> [User: Doctor]? {
            guard let codedDoctors = try? Data(contentsOf: ArchiveURLForDoctors) else {
                print("Failed to load doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            let doctors = try? propertyListDecoder.decode([User: Doctor].self, from: codedDoctors)
            return doctors
        }

        func saveDoctorsToFile() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedDoctors = try? propertyListEncoder.encode(doctors) {
                try? codedDoctors.write(to: DataModel.ArchiveURLForDoctors, options: .atomic)
            } else {
                print("Failed to save doctors data.")
            }
        }

        static func loadFromFilePatients() -> [User: Patient]? {
            guard let codedPatients = try? Data(contentsOf: ArchiveURLForPatients) else {
                print("Failed to load patients data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            let patients = try? propertyListDecoder.decode([User: Patient].self, from: codedPatients)
            return patients
        }

        func savePatientsToFile() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedPatients = try? propertyListEncoder.encode(patients) {
                try? codedPatients.write(to: DataModel.ArchiveURLForPatients, options: .atomic)
            } else {
                print("Failed to save patients data.")
            }
        }

        static func loadFromFileDoctorsForApproval() -> [Doctor]? {
            guard let codedDoctorsForApproval = try? Data(contentsOf: ArchiveURLForDoctorsForApproval) else {
                print("Failed to load doctors for approval data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            let doctorsForApproval = try? propertyListDecoder.decode([Doctor].self, from: codedDoctorsForApproval)
            return doctorsForApproval
        }

        func saveDoctorsForApprovalToFile() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedDoctorsForApproval = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedDoctorsForApproval.write(to: DataModel.ArchiveURLForDoctorsForApproval, options: .atomic)
            } else {
                print("Failed to save doctors for approval data.")
            }
        }

        func saveSpecialtiesToFile() {
            // Implement this function if you want to save the specialties to a file
        }
    }

    extension DataModel {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURLForDoctors = DocumentsDirectory.appendingPathComponent("doctors").appendingPathExtension("plist")
    static let ArchiveURLForPatients = DocumentsDirectory.appendingPathComponent("patients").appendingPathExtension("plist")
    static let ArchiveURLForDoctorsForApproval = DocumentsDirectory.appendingPathComponent("doctorsForApproval").appendingPathExtension("plist")
    }

    // Instantiate DataModel
    var dataModel = DataModel()
