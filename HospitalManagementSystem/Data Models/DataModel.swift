import Foundation
import SwiftUI
import Combine
import PhotosUI
import UniformTypeIdentifiers

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

struct Doctor: Codable  {
    var id: UUID { user.id }
    var user: User
    let specialty: String
    var medicalRegNumber: String
    var consultationFees: String
    var degree: String
    var previousPositions: String
    var biography: String
    var profilePicture: Data?
    var documents: [Data]
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
    @Published var specialties: [Specialty] = [
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
    @Published var doctorsForApprovalAndInTheDataBaseOfHospital: [Doctor] = []

    init() {
        self.admins = [:]
        self.doctors = DataModel.loadFromFileDoctors() ?? [:]
        self.patients = DataModel.loadFromFilePatients() ?? [:]
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
        self.doctorsForApprovalAndInTheDataBaseOfHospital = DataModel.loadFromFileDoctorsForApproval() ?? []
        initializeAdmins()
    }

    private func initializeAdmins() {
        let adminUser = User(email: Admin.adminEmail, phoneNumber: Admin.adminPhoneNumber, password: Admin.adminPassword, firstName: Admin.adminFirstName, lastName: Admin.adminLastName, age: Admin.adminAge, gender: Admin.adminGender, address: Admin.adminAddress)
        self.admins = [adminUser: Admin(user: adminUser)]
    }

    func signUpDoctor(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, gender: String, age: Int, address: String, specialty: String, medicalRegNumber: String, consultationFees: String, degree: String, previousPositions: String, biography: String, profilePicture: Data?, documents: [Data]) {
        let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, age: age, gender: gender, address: address)
        let newDoctor = Doctor(user: newUser, specialty: specialty, medicalRegNumber: medicalRegNumber, consultationFees: consultationFees, degree: degree, previousPositions: previousPositions, biography: biography, profilePicture: profilePicture, documents: documents)
        doctors[newUser] = newDoctor
        saveDoctorsToFile(doctors: doctors)
    }

    func signUpPatient(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, age: Int, gender: String, address: String) {
        let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, age: age, gender: gender, address: address)
        let newPatient = Patient(user: newUser)
        patients[newUser] = newPatient
        savePatientsToFile(patients: patients)
    }

    func signUp(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, userType: String, age: Int? = nil, gender: String = "", address: String = "", specialty: String = "", medicalRegNumber: String = "", consultationFees: String = "", degree: String = "", previousPositions: String = "", biography: String = "", profilePicture: Data? = nil, documents: [Data] = []) {
        switch userType {
        case "Doctor":
            if let age = age {
                signUpDoctor(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, gender: gender, age: age, address: address, specialty: specialty, medicalRegNumber: medicalRegNumber, consultationFees: consultationFees, degree: degree, previousPositions: previousPositions, biography: biography, profilePicture: profilePicture, documents: documents)
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

    static func loadFromFileDoctors() -> [User: Doctor]? {
        guard let codedDoctors = try? Data(contentsOf: ArchiveURLForDoctors) else {
            print("Failed to load doctors data from file.")
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        let doctors = try? propertyListDecoder.decode([User: Doctor].self, from: codedDoctors)
        print("Loaded doctors: \(doctors)")
        return doctors
    }

    func saveDoctorsToFile(doctors: [User: Doctor]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedDoctors = try? propertyListEncoder.encode(doctors) {
            try? codedDoctors.write(to: DataModel.ArchiveURLForDoctors, options: .atomic)
            print("Saved doctors: \(doctors)")
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
        print("Loaded patients: \(patients)")
        return patients
    }

    func savePatientsToFile(patients: [User: Patient]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedPatients = try? propertyListEncoder.encode(patients) {
            try? codedPatients.write(to: DataModel.ArchiveURLForPatients, options: .atomic)
            print("Saved patients: \(patients)")
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
        print("Loaded doctors for approval: \(doctorsForApproval)")
        return doctorsForApproval
    }

    func saveDoctorsForApprovalToFile(doctors: [Doctor]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedDoctorsForApproval = try? propertyListEncoder.encode(doctors) {
            try? codedDoctorsForApproval.write(to: DataModel.ArchiveURLForDoctorsForApproval, options: .atomic)
            print("Saved doctors for approval: \(doctors)")
        } else {
            print("Failed to save doctors for approval data.")
        }
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
}

extension DataModel {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURLForDoctors = DocumentsDirectory.appendingPathComponent("doctors").appendingPathExtension("plist")
    static let ArchiveURLForPatients = DocumentsDirectory.appendingPathComponent("patients").appendingPathExtension("plist")
    static let ArchiveURLForDoctorsForApproval = DocumentsDirectory.appendingPathComponent("doctorsForApproval").appendingPathExtension("plist")
}

// Instantiate DataModel
var dataModel = DataModel()
