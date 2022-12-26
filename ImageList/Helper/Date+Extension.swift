import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM YYYY"
    return formatter
}()

extension Date {
    var dateString: String { dateFormatter.string(from: self) }
}
