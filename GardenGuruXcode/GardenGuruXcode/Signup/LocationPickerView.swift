import SwiftUI

struct LocationPickerView: View {
    @Binding var selectedLocation: String
    @Environment(\.dismiss) private var dismiss
    
    // Common locations in India
    private let locations = [
        "North India",
        "South India",
        "East India",
        "West India",
        "Central India",
        "Northeast India",
        "Other"
    ]
    
    var body: some View {
        List(locations, id: \.self) { location in
            Button(action: {
                selectedLocation = location
                dismiss()
            }) {
                HStack {
                    Text(location)
                    Spacer()
                    if selectedLocation == location {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle("Select Location")
    }
}

#Preview {
    NavigationView {
        LocationPickerView(selectedLocation: .constant("North India"))
    }
} 