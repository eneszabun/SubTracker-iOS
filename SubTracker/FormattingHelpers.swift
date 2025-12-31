import Foundation

func sanitizeAmountInput(_ text: String) -> String {
    var result = ""
    var separatorUsed = false
    for char in text {
        if char.isNumber {
            result.append(char)
        } else if char == "." || char == "," {
            if !separatorUsed {
                separatorUsed = true
                result.append(",") // normalize to comma for UI
            }
        }
    }
    return result
}

extension Double {
    func cleanAmountString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}

extension String {
    var doubleValue: Double? { Double(self) }
}
