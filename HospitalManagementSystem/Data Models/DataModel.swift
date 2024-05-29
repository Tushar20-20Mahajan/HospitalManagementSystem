import SwiftUI

// User structure containing Email, PhoneNumber, and Password
struct User: Hashable {
    var email: String
    var phoneNumber: String
    var password: String
}

// Admin, Doctor, and Patient structures
struct Admin {
    var user: User
}

struct Doctor {
    var user: User
    var specialty: String
}

struct Patient {
    var user: User
    var medicalHistory: String
}

// DataModel class to manage users
class DataModel: ObservableObject {
    static let shared = DataModel()
    
    @Published var admin = Admin(user: User(email: "admin@hospital.com", phoneNumber: "9876543210", password: "12345678"))
    @Published var doctors: [Doctor] = [
        Doctor(user: User(email: "doctor1@hospital.com", phoneNumber: "1234567890", password: "doctor123"), specialty: "Cardiology"),
        Doctor(user: User(email: "doctor2@hospital.com", phoneNumber: "1234567891", password: "doctor456"), specialty: "Neurology")
    ]
    @Published var patients: [Patient] = [
        Patient(user: User(email: "patient1@hospital.com", phoneNumber: "2345678901", password: "patient123"), medicalHistory: "Diabetes"),
        Patient(user: User(email: "patient2@hospital.com", phoneNumber: "2345678902", password: "patient456"), medicalHistory: "Hypertension")
    ]
    
    // Authenticate user based on email and password
    func authenticate(email: String, password: String) -> Any? {
        if email == admin.user.email && password == admin.user.password {
            return admin
        }
        
        if let doctor = doctors.first(where: { $0.user.email == email && $0.user.password == password }) {
            return doctor
        }
        
        if let patient = patients.first(where: { $0.user.email == email && $0.user.password == password }) {
            return patient
        }
        
        return nil
    }
    
    // Add a new doctor
    func addDoctor(email: String, phoneNumber: String, password: String, specialty: String) {
        let newDoctor = Doctor(user: User(email: email, phoneNumber: phoneNumber, password: password), specialty: specialty)
        doctors.append(newDoctor)
    }
    
    // Add a new patient
    func addPatient(email: String, phoneNumber: String, password: String, medicalHistory: String) {
        let newPatient = Patient(user: User(email: email, phoneNumber: phoneNumber, password: password), medicalHistory: medicalHistory)
        patients.append(newPatient)
    }
    
    // Check if a user already exists
    func userExists(email: String) -> Bool {
        if email == admin.user.email {
            return true
        }
        
        if doctors.contains(where: { $0.user.email == email }) {
            return true
        }
        
        if patients.contains(where: { $0.user.email == email }) {
            return true
        }
        
        return false
    }
}

