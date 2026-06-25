import SwiftUI

struct SectionCard: View {
    let section: Section
    let color: Color
    
    var body: some View {
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
            color: .blue
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
            color: .purple
        )
    }
    .padding()
}
