import SwiftUI
import UniformTypeIdentifiers

struct SignUpView: View {
    @EnvironmentObject var dataModel: DataModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var address = ""
    
    @State private var userType = "Patient"
    @State private var isPasswordValid = false
    @State private var signUpAttempted = false
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("SignUp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Picker("User Type", selection: $userType) {
                    Text("Doctor").tag("Doctor")
                    Text("Patient").tag("Patient")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Group {
                    HStack {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    TextField("Age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    TextField("Address", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password, onCommit: {
                        validatePassword()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    SecureField("Confirm Password", text: $confirmPassword, onCommit: {
                        validatePassword()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    if !isPasswordValid && signUpAttempted {
                        Text("Passwords must match and have a minimum length of 6 characters.")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                Button(action: {
                    signUpAttempted = true
                    signUp()
                }) {
                    Text("Sign up")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                    Button(action: {
                        // Dismiss the current view
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Sign in")
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
    private func signUp() {
        // Ensure passwords match and have a minimum length of 6 characters
        guard password == confirmPassword, password.count >= 6 else {
            // Handle error: passwords do not match or have insufficient length
            isPasswordValid = false
            return
        }
        
        if userType == "Doctor" {
            dataModel.signUp(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, userType: userType, age: Int(age) ?? 0, gender: gender, address: address)
        } else {
            dataModel.signUp(email: email, phoneNumber: phoneNumber, password: password, firstName: firstName, lastName: lastName, userType: userType, age: Int(age) ?? 0, gender: gender, address: address)
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func validatePassword() {
        // Check if passwords match and have a minimum length of 6 characters
        isPasswordValid = password == confirmPassword && password.count >= 6
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(DataModel())
    }
}
