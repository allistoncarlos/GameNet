import SwiftUI

struct CurrencyTextField: View {

    // MARK: Internal

    let title: String
    @Binding var amountString: String

    var body: some View {
        TextField(title, text: $amountString)
            .keyboardType(.numberPad)
            .onChange(of: amountString, perform: { newValue in
                let valueFormatted = format(string: newValue)
                if amountString != valueFormatted {
                    amountString = valueFormatted
                }
            })
    }

    // MARK: Private

    private func format(string: String) -> String {
        let digits = string.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
        let value = (Double(digits) ?? 0) / 100.0

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = (Locale.current as NSLocale).object(forKey: .currencySymbol) as? String ?? ""

        let valueFormatted = currencyFormatter.string(from: NSNumber(value: value)) ?? ""
        return valueFormatted
    }
}
