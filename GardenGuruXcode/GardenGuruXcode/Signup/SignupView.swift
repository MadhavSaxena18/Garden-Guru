import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $viewModel.userName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                    
                    Text(viewModel.passwordRequirementText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                
                Section(header: Text("Location")) {
                    NavigationLink(destination: LocationPickerView(selectedLocation: $viewModel.location)) {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(viewModel.location.isEmpty ? "Select" : viewModel.location)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Reminders", isOn: $viewModel.reminderAllowed)
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.signUp()
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .disabled(!viewModel.isFormValid)
                    .listRowBackground(viewModel.isFormValid ? Color.green : Color.gray)
                }
            }
            .navigationTitle("Sign Up")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Account created successfully!")
            }
        }
    }
}

#Preview {
    SignupView()
} 