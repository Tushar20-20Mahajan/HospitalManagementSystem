import Foundation

struct User: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let email: String
    let phoneNumber: String
    let password: String
    let name: String
}

struct Admin: Codable {
    var user: User
    static let adminEmail = "admin@hospital.com"
    static let adminPhoneNumber = "9876543210"
    static let adminPassword = "12345678"
    static let adminName = "Admin"
}

struct Doctor: Codable {
    var user: User
}

struct Patient: Codable {
    var user: User
}

class DataModel: ObservableObject {
    @Published private var admins: [User: Admin]
    @Published private var doctors: [User: Doctor] = [:]
    @Published private var patients: [User: Patient] = [:]

    init() {
        self.admins = [:]
        self.doctors = [:]
        self.patients = [:]

        initializeAdmins()
        initializeDoctors()
        initializePatients()
    }

    private func initializeAdmins() {
        let adminUser = User(email: Admin.adminEmail, phoneNumber: Admin.adminPhoneNumber, password: Admin.adminPassword, name: Admin.adminName)
        self.admins = [adminUser: Admin(user: adminUser)]
    }

    private func initializeDoctors() {
        let doctorUser = User(email: "doctor@hospital.com", phoneNumber: "1234567890", password: "doctorpass", name: "Dr. Smith")
        self.doctors[doctorUser] = Doctor(user: doctorUser)
    }

    private func initializePatients() {
        let patientUser = User(email: "tushar@hospital.com", phoneNumber: "0987654321", password: "patientpass", name: "Tushar Mahajan")
        self.patients[patientUser] = Patient(user: patientUser)
    }

    // Retrieve doctors from file
    func getDoctorsFromFile() -> [User: Doctor]? {
        guard let codedDoctors = try? Data(contentsOf: DataModel.ArchiveURLForDoctors) else {
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([User: Doctor].self, from: codedDoctors)
    }

    // Save doctors to file
    func saveDoctorsToFile(doctors: [User: Doctor]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedDoctors = try? propertyListEncoder.encode(doctors) {
            try? codedDoctors.write(to: DataModel.ArchiveURLForDoctors, options: .withoutOverwriting)
        }
    }

    // Retrieve patients from file
    func getPatientsFromFile() -> [User: Patient]? {
        guard let codedPatients = try? Data(contentsOf: DataModel.ArchiveURLForPatients) else {
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([User: Patient].self, from: codedPatients)
    }

    // Save patients to file
    func savePatientsToFile(patients: [User: Patient]) {
        let propertyListEncoder = PropertyListEncoder()
        if let codedPatients = try? propertyListEncoder.encode(patients) {
            try? codedPatients.write(to: DataModel.ArchiveURLForPatients, options: .withoutOverwriting)
        }
    }

    // File URLs for doctors and patients data
    private static let ArchiveURLForDoctors = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("doctors").appendingPathExtension("plist")
    private static let ArchiveURLForPatients = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("patients").appendingPathExtension("plist")

    func signUp(email: String, phoneNumber: String, password: String, name: String, userType: String) {
        let newUser = User(email: email, phoneNumber: phoneNumber, password: password, name: name)

        switch userType {
        case "Doctor":
            let newDoctor = Doctor(user: newUser)
            doctors[newUser] = newDoctor
            saveDoctorsToFile(doctors: doctors)
        case "Patient":
            let newPatient = Patient(user: newUser)
            patients[newUser] = newPatient
            savePatientsToFile(patients: patients)
        default:
            break
        }
    }


    func signIn(email: String, password: String) -> (String, User?) {
        // Check for admin
        for (user, admin) in admins {
            if user.email == email && user.password == password {
                return ("Admin", user)
            }
        }

        // Check for doctor
        for (user, doctor) in doctors {
            if user.email == email && user.password == password {
                return ("Doctor", user)
            }
        }

        // Check for patient
        for (user, patient) in patients {
            if user.email == email && user.password == password {
                return ("Patient", user)
            }
        }

        return ("None", nil)
    }
}
// Instantiate DataModel
var dataModel = DataModel()
