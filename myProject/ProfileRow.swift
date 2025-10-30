import SwiftUI
struct ProfileRow: View {
    let label: String
    @Binding var value: String
    var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            if isEditing {
                TextField(label, text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(value)
                    .font(.body)
            }
        }
    }
}
