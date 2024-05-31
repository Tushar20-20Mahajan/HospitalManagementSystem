import Foundation
import SwiftUI
import Combine

struct User: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let email: String
    let phoneNumber: String
    let password: String
    let firstName: String
    let lastName: String

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
}

struct Doctor: Codable {
    var user: User
    let gender: String
    let qualification: String
    let specialization: String
    let medicalLicenceNumber: String
    let nmcCertificate: Data?
}

struct Patient: Codable {
    var user: User
    let age: Int
    let gender: String
    let address: String
}

class DataModel: ObservableObject {
    @Published private(set) var admins: [User: Admin] = [:]
    @Published private(set) var doctors: [User: Doctor] = [:]
    @Published private(set) var patients: [User: Patient] = [:]

    init() {
        self.admins = [:]
        self.doctors = DataModel.loadFromFileDoctors() ?? [:]
        self.patients = DataModel.loadFromFilePatients() ?? [:]
        initializeAdmins()
    }

    private func initializeAdmins() {
        let adminUser = User(email: Admin.adminEmail, phoneNumber: Admin.adminPhoneNumber, password: Admin.adminPassword, firstName: Admin.adminFirstName, lastName: Admin.adminLastName)
        self.admins = [adminUser: Admin(user: adminUser)]
    }

    func signUpDoctor(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, gender: String, qualification: String, specialization: String, medicalLicenceNumber: String, nmcCertificate: Data?) {
        let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName)
        let newDoctor = Doctor(user: newUser, gender: gender, qualification: qualification, specialization: specialization, medicalLicenceNumber: medicalLicenceNumber, nmcCertificate: nmcCertificate)
        doctors[newUser] = newDoctor
        saveDoctorsToFile(doctors: doctors)
    }

    func signUpPatient(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, age: Int, gender: String, address: String) {
        let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName)
        let newPatient = Patient(user: newUser, age: age, gender: gender, address: address)
        patients[newUser] = newPatient
        savePatientsToFile(patients: patients)
    }

    func signUp(email: String, phoneNumber: String, password: String, firstName: String, lastName: String, userType: String, age: Int? = nil, gender: String = "", qualification: String = "", specialization: String = "", medicalLicenceNumber: String = "", nmcCertificate: Data? = nil, address: String = "") {
        switch userType {
        case "Doctor":
            signUpDoctor(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, gender: gender, qualification: qualification, specialization: specialization, medicalLicenceNumber: medicalLicenceNumber, nmcCertificate: nmcCertificate)
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

    // Retrieve doctors from file
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

    // Save doctors to file
    func saveDoctorsToFile(doctors: [User: Doctor]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedDoctors = try? propertyListEncoder.encode(doctors) {
            try? codedDoctors.write(to: DataModel.ArchiveURLForDoctors, options: .atomic)
            print("Saved doctors: \(doctors)")
        } else {
            print("Failed to save doctors data.")
        }
    }

    // Retrieve patients from file
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

    // Save patients to file
    func savePatientsToFile(patients: [User: Patient]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedPatients = try? propertyListEncoder.encode(patients) {
            try? codedPatients.write(to: DataModel.ArchiveURLForPatients, options: .atomic)
            print("Saved patients: \(patients)")
        } else {
            print("Failed to save patients data.")
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
}

// Instantiate DataModel
var dataModel = DataModel()
