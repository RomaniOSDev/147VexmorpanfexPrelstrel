import Foundation
import UIKit

/// Внешние URL приложения (privacy, terms). Подставьте реальные ссылки для продакшена.
enum AppExternalURL: String {
    case privacyPolicy = "https://vexmorpanfex147prelstrel.site/privacy/123"
    case termsOfService = "https://vexmorpanfex147prelstrel.site/terms/123"

    var url: URL? { URL(string: rawValue) }

    func openInBrowser() {
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
}
