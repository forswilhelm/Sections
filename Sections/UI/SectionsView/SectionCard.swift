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
    }
}

#Preview {
    HStack(spacing: 16) {
        SectionCard(
            section: Section(
                id: "1",
                title: "Serier",
                href: "https://example.com",
                type: "vod",
                sectionSort: 1,
                name: "series",
                templated: true
            ),
            color: .blue,
            onTap: { print("Tapped Serier") }
        )
        
        SectionCard(
            section: Section(
                id: "2",
                title: "Filmer",
                href: "https://example.com",
                type: "vod",
                sectionSort: 2,
                name: "movie",
                templated: true
            ),
            color: .purple,
            onTap: { print("Tapped Filmer") }
        )
    }
    .padding()
}
