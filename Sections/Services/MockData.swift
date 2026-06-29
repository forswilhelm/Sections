import Foundation

/// Mock data for previews and testing
enum MockData {
    static let sections = [
        Section(
            id: "1",
            title: "Serier",
            href: "https://content.viaplay.com/ios-se/serier",
            type: "vod",
            sectionSort: 1,
            name: "series",
            templated: true
        ),
        Section(
            id: "2",
            title: "Filmer",
            href: "https://content.viaplay.com/ios-se/filmer",
            type: "vod",
            sectionSort: 2,
            name: "movie",
            templated: true
        ),
        Section(
            id: "3",
            title: "Sport",
            href: "https://content.viaplay.com/ios-se/sport",
            type: "sport",
            sectionSort: 3,
            name: "sport",
            templated: false
        ),
        Section(
            id: "4",
            title: "Barn",
            href: "https://content.viaplay.com/ios-se/barn",
            type: "vod",
            sectionSort: 4,
            name: "kids",
            templated: true
        ),
    ]
    
    static let sectionDetail = SectionDetailed(
        title: "Swedish Series",
        description: "Explore our wide selection of Swedish and international series. From thrilling dramas to captivating documentaries, find your next favorite show here."
    )
}
