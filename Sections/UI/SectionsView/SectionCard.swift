import SwiftUI

struct SectionCard: View {
    let section: Section
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                
                Text(section.title.uppercased())
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
            )
            .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Section: \(section.title)")
        .accessibilityHint("Double tap to view details")
    }
}

#Preview {
    HStack(spacing: 16) {
        SectionCard(
            section: MockData.sections[0],
            color: .blue,
            onTap: { print("Tapped Serier") }
        )
        
        SectionCard(
            section: MockData.sections[1],
            color: .purple,
            onTap: { print("Tapped Filmer") }
        )
    }
    .padding()
}
