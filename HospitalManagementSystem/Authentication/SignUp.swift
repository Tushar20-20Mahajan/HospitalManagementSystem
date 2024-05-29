import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isDoctor = true
    @State private var showSignIn = false
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            HStack {
                Button(action: {
                    isDoctor = true
                }) {
                    Text("Doctor")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDoctor ? Color.blue : Color.clear)
                        .foregroundColor(isDoctor ? Color.white : Color.gray)
                        .cornerRadius(10)
                }
                Button(action: {
                    isDoctor = false
                }) {
                    Text("Patient")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDoctor ? Color.clear : Color.blue)
                        .foregroundColor(isDoctor ? Color.gray : Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)
            
            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            Button(action: {
                if password == confirmPassword {
                    if isDoctor {
                        DataModel.shared.addDoctor(email: email, phoneNumber: phoneNumber, password: password, specialty: "Cardiology")
                    } else {
                        DataModel.shared.addPatient(email: email, phoneNumber: phoneNumber, password: password, medicalHistory: "Neurology")
                    }
                    showSignIn = true
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Button(action: {
                showSignIn = true
            }) {
                Text("Already have an account? Sign In")
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showSignIn) {
            SignInView()
        }
    }
}

