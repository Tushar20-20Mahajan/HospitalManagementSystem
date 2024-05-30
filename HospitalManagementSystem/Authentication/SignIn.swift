import SwiftUI

struct SignInView: View {
    @EnvironmentObject var dataModel: DataModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var userType = ""
    @State private var user: User?
    @State private var signInSuccess = false
    @State private var signInFailed = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 80)
            
            Text("Hello again!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
            
            Text("Welcome back you've been missed!")
                .font(.body)
                .foregroundColor(Color.gray)
                .padding(.top, 5)
            
            TextField("Email", text: $email)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)
            
            SecureField("Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            HStack {
                Spacer()
                Button(action: {
                    // Handle forgot password action
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 20)
            }
            
            Spacer()
                .frame(height: 20)
            
            Button("Sign In") {
                let (userType, user) = dataModel.signIn(email: email, password: password)
                if let user = user {
                    self.userType = userType
                    self.user = user
                    self.signInSuccess = true
                } else {
                    self.signInFailed = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            
            Text("Or")
                .padding(.top, 10)
            
            Button(action: {
                // Handle Apple login action
            }) {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Sign In with Apple")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button(action: {
                    showingSignUp.toggle()
                }) {
                    Text("Sign up")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)
            .fullScreenCover(isPresented: $showingSignUp) {
                SignUpView()
            }

            
            if signInFailed {
                Text("Unauthorized user. Please check your credentials.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .onChange(of: signInSuccess) { newValue in
            if newValue {
                print("SignIn Success: \(userType), \(user)")
            }
        }
        .fullScreenCover(isPresented: $signInSuccess) {
            if let user = user {
                HomeView(userType: userType, user: user)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView().environmentObject(DataModel())
    }
}
