//
//  DoctorProfile.swift
//  HospitalManagementSystem
//
//  Created by Akshay Jha on 31/05/24.
//

import SwiftUI

struct DoctorProfile: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isHealthDetailsPresented = false
    var userType: String
    var user: User
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
                .background(Color(red: 241/255, green: 241/255, blue: 246/255))
                
                List {
                    VStack(spacing: 0) {
                        Image("User2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .background(Color(.gray))
                            .clipShape(Circle())
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color(red: 241/255, green: 241/255, blue: 246/255))
                    .listRowInsets(EdgeInsets())
                    
                    Group {
                        NavigationLink(destination: HealthDetailsDoctorView(userType: "Doctor", user: user)) {
                            Text("Personal information")
                        }
                        NavigationLink(destination: Text("Medical Credentials View")) {
                            Text("Medical Credentials")
                        }
                    }
                    
                    Section(header: Text("Features")
                                .font(.title3)
                                .textCase(.none)
                                .foregroundColor(.black)) {
                        NavigationLink(destination: Text("Subscriptions View")) {
                            Text("Subscriptions")
                        }
                        NavigationLink(destination: Text("Notifications View")) {
                            Text("Notifications")
                        }
                    }
                    
                    Section(header: Text("Privacy")
                                .font(.title3)
                                .textCase(.none)
                                .foregroundColor(.black)) {
                        NavigationLink(destination: Text("Apps and Services View")) {
                            Text("Apps and Services")
                        }
                        NavigationLink(destination: Text("Research Studies View")) {
                            Text("Research Studies")
                        }
                        NavigationLink(destination: Text("Devices View")) {
                            Text("Devices")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your data is encrypted on your device and can only be shared with your permission.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 100)
                    }
                    .background(Color(red: 241/255, green: 241/255, blue: 246/255))
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isHealthDetailsPresented) {
//                HealthDetailsView1(userType: "Patient", user: User)
            }
        }
    }
}

//#Preview {
//    DoctorProfile()
//}



struct HealthDetailsDoctorView: View {
    
    var userType: String
    var user: User
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    Image("User2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 87)
                        .background(Color(.gray))
                        .clipShape(Circle())
                    Spacer()
                }
                .padding(.vertical, 20)
                
                Form {
                    Section {
                        HStack {
                            Text("First Name")
                            Spacer()
                            Text("\(user.firstName)")
                                .foregroundColor(.black)
                        }
                        .frame(height: 36)
                        
                        HStack {
                            Text("Last Name")
                            Spacer()
                            Text(" \(user.lastName)")
                                .foregroundColor(.black)
                        }
                        .frame(height: 36)
                        
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(user.age)")
                                .foregroundColor(.black)
                        }
                        .frame(height: 40)
                        
                        HStack {
                            Text("Sex")
                            Spacer()
                            Text("\(user.gender)")
                                .foregroundColor(.black)
                        }
                        .frame(height: 40)
                        
                        HStack {
                            Text("Blood Type")
                            Spacer()
                            Text("A+")
                                .foregroundColor(.black)
                        }
                        .frame(height: 40)
                        
                        HStack {
                            Text("Medications That Affect Heart Rate")
                            Spacer()
                            Text("0")
                                .foregroundColor(.black)
                        }
                        .frame(height: 40)
                        
                       
                        
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}


