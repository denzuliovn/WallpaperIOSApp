import Foundation

struct PixabayResponse: Codable {
    let hits: [PixabayImage]
}

struct PixabayImage: Codable {
    let id: Int
    let webformatURL: String
}
