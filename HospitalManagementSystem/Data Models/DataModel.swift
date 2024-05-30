import Foundation

struct User: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let email: String
    let phoneNumber: String
    let password: String
    let firstName: String
    let lastName: String
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
        let adminUser = User(email: Admin.adminEmail, phoneNumber: Admin.adminPhoneNumber, password: Admin.adminPassword, firstName: Admin.adminFirstName, lastName: Admin.adminLastName)
        self.admins = [adminUser: Admin(user: adminUser)]
    }

    private func initializeDoctors() {
        let doctorUser = User(email: "doctor@hospital.com", phoneNumber: "1234567890", password: "doctorpass", firstName: "John", lastName: "Smith")
        self.doctors[doctorUser] = Doctor(user: doctorUser, gender: "Male", qualification: "MBBS", specialization: "Cardiology", medicalLicenceNumber: "123456", nmcCertificate: nil)
    }

    private func initializePatients() {
            let patientUser = User(email: "patient@hospital.com", phoneNumber: "0987654321", password: "patientpass", firstName: "Tushar", lastName: "Mahajan")
            self.patients[patientUser] = Patient(user: patientUser, age: 30, gender: "Male", address: "")
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
            let newUser = User(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName)

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
