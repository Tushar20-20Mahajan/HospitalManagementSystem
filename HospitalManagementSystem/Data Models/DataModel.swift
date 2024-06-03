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
            Specialty(imageName: "heart", name: "Cardiologist", description: "Heart and Blood vessels", doctors: DataModel.loadFromFileCardiologist() ?? []),
            Specialty(imageName: "rash", name: "Dermatology", description: "Skin, hair, and nails.", doctors: DataModel.loadFromFileDermotology() ?? []),
            Specialty(imageName: "heel", name: "Anesthesiology", description: "Pain relief", doctors: DataModel.loadFromFileAnesthesiology() ?? []),
            Specialty(imageName: "stomach", name: "Gastroenterology", description: "Digestive system disorders", doctors: DataModel.loadFromFileGastroenterology() ?? []),
            Specialty(imageName: "brain", name: "Neurologist", description: "Brain and neurons", doctors: DataModel.loadFromFileNeurologist() ?? []),
            Specialty(imageName: "uterus", name: "Gynecologist", description: "Female reproductive system", doctors: DataModel.loadFromFileGynecologist() ?? []),
            Specialty(imageName: "ortho", name: "Orthopedic", description: "Bones and joints", doctors: DataModel.loadFromFileOrthopedic() ?? []),
            Specialty(imageName: "Teeth", name: "Dentist", description: "Teeth and oral health", doctors: DataModel.loadFromFileDentist() ?? []),
            Specialty(imageName: "Phisio", name: "Physiotherapist", description: "Physical therapy", doctors: DataModel.loadFromFilePhysiotherapist() ?? [])
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
    // Method to load Cardiologist doctors from file
        static func loadFromFileCardiologist() -> [Doctor]? {
            guard let codedCardiologists = try? Data(contentsOf: ArchiveURLForCardiologist) else {
                print("Failed to load Cardiologist doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Cardiologist doctors data from file.")
            let cardiologists = try? propertyListDecoder.decode([Doctor].self, from: codedCardiologists)
            return cardiologists
        }

        // Method to save Cardiologist doctors to file
        func saveDoctorsToCardiologist() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedCardiologists = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedCardiologists.write(to: DataModel.ArchiveURLForCardiologist, options: .atomic)
            } else {
                print("Failed to save Cardiologist doctors data.")
            }
        }
    
    // Method to load Dermotology doctors from file
        static func loadFromFileDermotology() -> [Doctor]? {
            guard let codedDermotology = try? Data(contentsOf: ArchiveURLForDermotology) else {
                print("Failed to load Dermotology doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Dermotology doctors data from file.")
            let dermotology = try? propertyListDecoder.decode([Doctor].self, from: codedDermotology)
            return dermotology
        }

        // Method to save Dermotology doctors to file
        func saveDoctorsToDermotology() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedDermotology = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedDermotology.write(to: DataModel.ArchiveURLForDermotology, options: .atomic)
            } else {
                print("Failed to save Dermotology doctors data.")
            }
        }
    
    // Method to load Anesthesiology doctors from file
        static func loadFromFileAnesthesiology() -> [Doctor]? {
            guard let codedAnesthesiology = try? Data(contentsOf: ArchiveURLForAnesthesiology) else {
                print("Failed to load Anesthesiology doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Anesthesiology doctors data from file.")
            let anesthesiology = try? propertyListDecoder.decode([Doctor].self, from: codedAnesthesiology)
            return anesthesiology
        }

        // Method to save Anesthesiology doctors to file
        func saveDoctorsToAnesthesiology() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedAnesthesiology = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedAnesthesiology.write(to: DataModel.ArchiveURLForAnesthesiology, options: .atomic)
            } else {
                print("Failed to save Anesthesiology doctors data.")
            }
        }
    
    // Method to load Gastroenterology doctors from file
        static func loadFromFileGastroenterology() -> [Doctor]? {
            guard let codedGastroenterology = try? Data(contentsOf: ArchiveURLForGastroenterology) else {
                print("Failed to load Gastroenterology doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Gastroenterology doctors data from file.")
            let gastroenterology = try? propertyListDecoder.decode([Doctor].self, from: codedGastroenterology)
            return gastroenterology
        }

        // Method to save Gastroenterology doctors to file
        func saveDoctorsToGastroenterology() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedGastroenterology = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedGastroenterology.write(to: DataModel.ArchiveURLForGastroenterology, options: .atomic)
            } else {
                print("Failed to save Gastroenterology doctors data.")
            }
        }
    
    // Method to load Neurologist doctors from file
        static func loadFromFileNeurologist() -> [Doctor]? {
            guard let codedNeurologist = try? Data(contentsOf: ArchiveURLForNeurologist) else {
                print("Failed to load Neurologist doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Neurologist doctors data from file.")
            let neurologist = try? propertyListDecoder.decode([Doctor].self, from: codedNeurologist)
            return neurologist
        }

        // Method to save Neurologist doctors to file
        func saveDoctorsToNeurologist() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedNeurologist = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedNeurologist.write(to: DataModel.ArchiveURLForNeurologist, options: .atomic)
            } else {
                print("Failed to save Neurologist doctors data.")
            }
        }
    
    // Method to load Gynecologist doctors from file
        static func loadFromFileGynecologist() -> [Doctor]? {
            guard let codedGynecologist = try? Data(contentsOf: ArchiveURLForGynecologist) else {
                print("Failed to load Gynecologist doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Gynecologist doctors data from file.")
            let gynecologist = try? propertyListDecoder.decode([Doctor].self, from: codedGynecologist)
            return gynecologist
        }

        // Method to save Gynecologist doctors to file
        func saveDoctorsToGynecologist() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedGynecologist = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedGynecologist.write(to: DataModel.ArchiveURLForGynecologist, options: .atomic)
            } else {
                print("Failed to save Gynecologist doctors data.")
            }
        }
    
    // Method to load Orthopedic doctors from file
    static func loadFromFileOrthopedic() -> [Doctor]? {
        guard let codedOrthopedic = try? Data(contentsOf: ArchiveURLForOrthopedic) else {
            print("Failed to load Orthopedic doctors data from file.")
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        print(" loaded Orthopedic doctors data from file.")
        let orthopedic = try? propertyListDecoder.decode([Doctor].self, from: codedOrthopedic)
        return orthopedic
    }

    // Method to save Orthopedic doctors to file
    func saveDoctorsToOrthopedic() {
        let propertyListEncoder = PropertyListEncoder()
        if let codedOrthopedic = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
            try? codedOrthopedic.write(to: DataModel.ArchiveURLForOrthopedic, options: .atomic)
        } else {
            print("Failed to save Orthopedic doctors data.")
        }
    }
    
    // Method to load Dentist doctors from file
        static func loadFromFileDentist() -> [Doctor]? {
            guard let codedDentist = try? Data(contentsOf: ArchiveURLForDentist) else {
                print("Failed to load Dentist doctors data from file.")
                return nil
            }
            let propertyListDecoder = PropertyListDecoder()
            print(" loaded Dentist doctors data from file.")
            let dentist = try? propertyListDecoder.decode([Doctor].self, from: codedDentist)
            return dentist
        }

        // Method to save Dentist doctors to file
        func saveDoctorsToDentist() {
            let propertyListEncoder = PropertyListEncoder()
            if let codedDentist = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
                try? codedDentist.write(to: DataModel.ArchiveURLForDentist, options: .atomic)
            } else {
                print("Failed to save Dentist doctors data.")
            }
        }
    
    // Method to load Physiotherapist doctors from file
    static func loadFromFilePhysiotherapist() -> [Doctor]? {
        guard let codedPhysiotherapist = try? Data(contentsOf: ArchiveURLForPhysiotherapist) else {
            print("Failed to load Physiotherapist doctors data from file.")
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        print(" loaded Physiotherapist doctors data from file.")
        let physiotherapist = try? propertyListDecoder.decode([Doctor].self, from: codedPhysiotherapist)
        return physiotherapist
    }

    // Method to save Physiotherapist doctors to file
    func saveDoctorsToPhysiotherapist() {
        let propertyListEncoder = PropertyListEncoder()
        if let codedPhysiotherapist = try? propertyListEncoder.encode(doctorsForApprovalAndInTheDataBaseOfHospital) {
            try? codedPhysiotherapist.write(to: DataModel.ArchiveURLForPhysiotherapist, options: .atomic)
        } else {
            print("Failed to save Physiotherapist doctors data.")
        }
    }
    
    // Remove a doctor from the list
      func removeDoctorForApproval(at index: Int) -> Doctor? {
          // Ensure the index is valid before removing the doctor
          guard index >= 0 && index < doctorsForApprovalAndInTheDataBaseOfHospital.count else {
              return nil
          }
          let removedDoctor = doctorsForApprovalAndInTheDataBaseOfHospital.remove(at: index)
          saveDoctorsForApprovalToFile()
          return removedDoctor
      }
    
    
    
    func approveDoctor(_ doctor: Doctor) {
        if let index = specialties.firstIndex(where: { $0.name == doctor.specialty }) {
            specialties[index].doctors.append(doctor)
        } else {
            let newSpecialty = Specialty(imageName: "defaultImage", name: doctor.specialty, description: "", doctors: [doctor])
            specialties.append(newSpecialty)
        }
        if let index = doctorsForApprovalAndInTheDataBaseOfHospital.firstIndex(where: { $0.id == doctor.id }) {
            removeDoctorForApproval(at: index)
        }
    }


    func rejectDoctor(_ doctor: Doctor) {
        doctorsForApprovalAndInTheDataBaseOfHospital.removeAll { $0.id == doctor.id }
        saveDoctorsForApprovalToFile()
    }

    func saveSpecialtyDoctors(for specialty: String) {
        switch specialty {
        case "Cardiologist":
            saveDoctorsToCardiologist()
        case "Dermatology":
            saveDoctorsToDermotology()
        case "Anesthesiology":
            saveDoctorsToAnesthesiology()
        case "Gastroenterology":
            saveDoctorsToGastroenterology()
        case "Neurologist":
            saveDoctorsToNeurologist()
        case "Gynecologist":
            saveDoctorsToGynecologist()
        case "Orthopedic":
            saveDoctorsToOrthopedic()
        case "Dentist":
            saveDoctorsToDentist()
        case "Physiotherapist":
            saveDoctorsToPhysiotherapist()
        default:
            break
        }
    }



}

extension DataModel {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURLForDoctors = DocumentsDirectory.appendingPathComponent("doctors").appendingPathExtension("plist")
    static let ArchiveURLForPatients = DocumentsDirectory.appendingPathComponent("patients").appendingPathExtension("plist")
    static let ArchiveURLForDoctorsForApproval = DocumentsDirectory.appendingPathComponent("doctorsForApproval").appendingPathExtension("plist")
    static let ArchiveURLForCardiologist = DocumentsDirectory.appendingPathComponent("cardiologists").appendingPathExtension("plist")
    static let ArchiveURLForDermotology = DocumentsDirectory.appendingPathComponent("dermotology").appendingPathExtension("plist")
    static let ArchiveURLForAnesthesiology = DocumentsDirectory.appendingPathComponent("anesthesiology").appendingPathExtension("plist")
    static let ArchiveURLForGastroenterology = DocumentsDirectory.appendingPathComponent("gastroenterology").appendingPathExtension("plist")
    static let ArchiveURLForNeurologist = DocumentsDirectory.appendingPathComponent("neurologist").appendingPathExtension("plist")
    static let ArchiveURLForGynecologist = DocumentsDirectory.appendingPathComponent("gynecologist").appendingPathExtension("plist")
    static let ArchiveURLForOrthopedic = DocumentsDirectory.appendingPathComponent("orthopedic").appendingPathExtension("plist")
    static let ArchiveURLForDentist = DocumentsDirectory.appendingPathComponent("dentist").appendingPathExtension("plist")
    static let ArchiveURLForPhysiotherapist = DocumentsDirectory.appendingPathComponent("physiotherapist").appendingPathExtension("plist")
   
    
    
}


    // Instantiate DataModel
    var dataModel = DataModel()
