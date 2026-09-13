enum PersistenceKeys: String, CustomStringConvertible {
    var description: String { rawValue }

    case id
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
    case annualChartVisibleDomainLength = "annual_chart_visible_domain_length"
    case annualChartHiddenYears = "annual_chart_hidden_years"
}
