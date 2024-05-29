import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showAdminInterface = false
    @State private var showDoctorInterface = false
    @State private var showPatientInterface = false
    
    var body: some View {
        VStack {
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            Button(action: {
                let authenticatedUser = DataModel.shared.authenticate(email: email, password: password)
                
                if let admin = authenticatedUser as? Admin {
                    showAdminInterface = true
                } else if let doctor = authenticatedUser as? Doctor {
                    showDoctorInterface = true
                } else if let patient = authenticatedUser as? Patient {
                    showPatientInterface = true
                }
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Button(action: {
                showSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView()
        }
        .fullScreenCover(isPresented: $showAdminInterface) {
            AdminInterfaceView()
        }
        .fullScreenCover(isPresented: $showDoctorInterface) {
            DoctorInterfaceView()
        }
        .fullScreenCover(isPresented: $showPatientInterface) {
            PatientInterfaceView()
        }
    }
}

