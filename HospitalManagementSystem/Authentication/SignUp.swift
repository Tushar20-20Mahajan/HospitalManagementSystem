// SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var name = ""
    @State private var userType = "Patient"
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("User Type", selection: $userType) {
                Text("Doctor").tag("Doctor")
                Text("Patient").tag("Patient")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Sign Up") {
                dataModel.signUp(email: email, phoneNumber: phoneNumber, password: password, name: name, userType: userType)
                self.presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}
