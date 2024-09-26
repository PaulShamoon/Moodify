//
//  AccountInfoView.swift
//  Moodify
//
//  Created by Mahdi Sulaiman on 9/25/24.
//
import SwiftUI

struct AccountInfoView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: Int = 0
    @State private var gender: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Information")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 20)

            Text("First Name: \(firstname)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Last Name: \(lastname)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Age: \(age)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Gender: \(gender)")
                .font(.title2)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            loadUserData()
        }
    }

    // Function to load data from UserDefaults
    func loadUserData() {
        firstname = UserDefaults.standard.string(forKey: "firstname") ?? "Unknown"
        lastname = UserDefaults.standard.string(forKey: "lastname") ?? "Unknown"
        age = UserDefaults.standard.integer(forKey: "age")
        gender = UserDefaults.standard.string(forKey: "gender") ?? "Unknown"
    }
}

