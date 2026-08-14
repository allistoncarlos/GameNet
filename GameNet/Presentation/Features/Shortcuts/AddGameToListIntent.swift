//
//  AddGameToListIntent.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct AddGameToListIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to List"
    static var description = IntentDescription(
        "Adds a game from your library to one of your lists. If more than one game matches, you can pick the right one."
    )

    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$game) to \(\.$list)")
    }

    @Parameter(title: "List")
    var list: ListEntity

    @Parameter(title: "Game")
    var game: GameEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = await AddGameToListService.make().add(gameId: game.id, listId: list.id)

        switch result {
        case let .added(gameName, listName):
            return .result(dialog: "Added \(gameName) to \(listName).")
        case let .alreadyInList(gameName, listName):
            return .result(dialog: "\(gameName) is already in \(listName).")
        case .listNotFound:
            return .result(dialog: "I couldn't find that list.")
        case .gameNotFound:
            return .result(dialog: "I couldn't find that game in your library.")
        case .notLoggedIn:
            return .result(dialog: "Open GameNet and sign in, then try again.")
        case .saveFailed:
            return .result(dialog: "I couldn't add that game to the list.")
        }
    }
}
#endif
