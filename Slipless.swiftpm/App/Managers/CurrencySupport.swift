import Foundation

enum CurrencySupport {
    static var currentCurrencyCode: String {
        Locale.autoupdatingCurrent.currency?.identifier ?? "USD"
    }

    static var currentCurrencyDisplay: String {
        Locale.autoupdatingCurrent.currencySymbol ?? currentCurrencyCode
    }
}