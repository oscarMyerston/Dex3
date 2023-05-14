//
//  FetchController.swift
//  Dex3
//
//  Created by Oscar David Myerston Vega on 19/03/23.
//

import Foundation
import CoreData

struct FetchController {

    enum NetworkError: Error {
        case badURL, badResponse, badData
    }

    private let baseURL = URL(string: "https://pokeapi.co/api/v2pokemon")!

    func fetchAllPokemon() async throws -> [TempPokemon]? {
        if havePokemon() {
            return nil
        }
        var allPokemon: [TempPokemon] = []

        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]

        guard let fetchURL = fetchComponents?.url else { throw NetworkError.badURL }

        let (data, response) = try await URLSession.shared.data(from: fetchURL)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw NetworkError.badData
        }

        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPockemon(from: URL(string: url)!))
            }
        }
        return allPokemon
    }

    private func fetchPockemon(from url: URL) async throws -> TempPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        let tempPoken = try JSONDecoder().decode(TempPokemon.self, from: data)
        debugPrint("Fetched \(tempPoken.id): \(tempPoken.name)")
        return tempPoken
    }

    private func havePokemon() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])

        do {
            let checkPokemon = try context.fetch(fetchRequest)
            if checkPokemon.count == 2 {
                return true
            }
        } catch {
            debugPrint("Fetch failed: \(error)")
            return false
        }
        return false
    }

}
