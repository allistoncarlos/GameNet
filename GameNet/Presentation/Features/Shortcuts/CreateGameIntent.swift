//
//  CreateGameIntent.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct CreateGameIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Game"
    static var description = IntentDescription(
        "Searches TheGamesDB for box art and creates a game on the chosen platform."
    )

    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Create \(\.$name) on \(\.$platform)")
    }

    @Parameter(title: "Name")
    var name: String

    @Parameter(title: "Platform")
    var platform: PlatformEntity

    @Parameter(title: "Catalog Game")
    var catalogGame: CatalogGameEntity?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = CreateGameService.make()
        let platforms = await service.platforms()
        guard let selectedPlatform = platforms.first(where: { $0.id == platform.id }) else {
            return .result(dialog: "I couldn't find that platform.")
        }

        let result = await service.create(
            name: name,
            platform: selectedPlatform,
            catalogGame: catalogGame?.asCatalogGame
        )

        switch result {
        case let .created(gameName, platformName):
            return .result(dialog: "Created \(gameName) on \(platformName).")
        case let .needsGameChoice(games):
            let entities = games.map {
                CatalogGameEntity(
                    id: String($0.id),
                    catalogId: $0.id,
                    name: $0.name,
                    platformName: $0.platformName,
                    released: $0.released
                )
            }
            let chosen = try await $catalogGame.requestDisambiguation(
                among: entities,
                dialog: IntentDialog("Which game is \(name)?")
            )
            let retry = await service.create(
                name: name,
                platform: selectedPlatform,
                catalogGame: chosen.asCatalogGame
            )
            if case let .created(gameName, platformName) = retry {
                return .result(dialog: "Created \(gameName) on \(platformName).")
            }
            return .result(dialog: dialog(for: retry))
        default:
            return .result(dialog: dialog(for: result))
        }
    }

    private func dialog(for result: CreateGameResult) -> IntentDialog {
        switch result {
        case let .created(gameName, platformName):
            return "Created \(gameName) on \(platformName)."
        case .needsGameChoice:
            return "I found more than one game with that name."
        case .notLoggedIn:
            return "Open GameNet and sign in, then try again."
        case .missingAPIKey:
            return "TheGamesDB API key is missing."
        case .platformNotFound:
            return "I couldn't find that platform."
        case .gameNotFound:
            return "I couldn't find that game on TheGamesDB."
        case .coverDownloadFailed:
            return "I couldn't download the box art."
        case .saveFailed:
            return "I couldn't save that game."
        }
    }
}
#endif
