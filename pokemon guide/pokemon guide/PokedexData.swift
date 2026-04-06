//
//  PokedexData.swift
//  pokemon guide
//
//  Los 151 Pokémon de Kanto con tipos, estadísticas y ubicaciones.
//

import SwiftUI

// MARK: - Pokemon Type

enum PokemonType: String, CaseIterable {
    case normal, fire, water, grass, electric, ice
    case fighting, poison, ground, flying, psychic
    case bug, rock, ghost, dragon, steel

    var color: Color {
        switch self {
        case .normal:   return Color(red: 0.66, green: 0.65, blue: 0.56)
        case .fire:     return Color(red: 0.93, green: 0.51, blue: 0.19)
        case .water:    return Color(red: 0.39, green: 0.56, blue: 0.94)
        case .grass:    return Color(red: 0.47, green: 0.78, blue: 0.30)
        case .electric: return Color(red: 0.97, green: 0.82, blue: 0.17)
        case .ice:      return Color(red: 0.58, green: 0.85, blue: 0.84)
        case .fighting: return Color(red: 0.76, green: 0.18, blue: 0.16)
        case .poison:   return Color(red: 0.64, green: 0.24, blue: 0.63)
        case .ground:   return Color(red: 0.88, green: 0.75, blue: 0.40)
        case .flying:   return Color(red: 0.66, green: 0.56, blue: 0.95)
        case .psychic:  return Color(red: 0.98, green: 0.33, blue: 0.53)
        case .bug:      return Color(red: 0.65, green: 0.73, blue: 0.10)
        case .rock:     return Color(red: 0.71, green: 0.63, blue: 0.38)
        case .ghost:    return Color(red: 0.44, green: 0.34, blue: 0.58)
        case .dragon:   return Color(red: 0.44, green: 0.21, blue: 0.99)
        case .steel:    return Color(red: 0.72, green: 0.72, blue: 0.82)
        }
    }

    var icon: String {
        switch self {
        case .normal: return "circle.fill"
        case .fire: return "flame.fill"
        case .water: return "drop.fill"
        case .grass: return "leaf.fill"
        case .electric: return "bolt.fill"
        case .ice: return "snowflake"
        case .fighting: return "figure.martial.arts"
        case .poison: return "allergens.fill"
        case .ground: return "mountain.2.fill"
        case .flying: return "wind"
        case .psychic: return "eye.fill"
        case .bug: return "ant.fill"
        case .rock: return "diamond.fill"
        case .ghost: return "aqi.medium"
        case .dragon: return "flame.fill"
        case .steel: return "shield.fill"
        }
    }
}

// MARK: - Pokemon Stats

struct PokemonStats: Codable {
    let hp: Int
    let attack: Int
    let defense: Int
    let spAttack: Int
    let spDefense: Int
    let speed: Int

    var total: Int {
        hp + attack + defense + spAttack + spDefense + speed
    }
}

// MARK: - Pokemon Status

enum PokemonStatus: Int, Codable, CaseIterable {
    case notSeen = 0
    case seen = 1
    case caught = 2
    case evolved = 3

    var label: String {
        switch self {
        case .notSeen: return "No visto"
        case .seen:    return "Visto"
        case .caught:  return "Capturado"
        case .evolved: return "Evolucionado"
        }
    }

    var icon: String {
        switch self {
        case .notSeen: return "questionmark.circle"
        case .seen:    return "eye.fill"
        case .caught:  return "circle.circle.fill"
        case .evolved: return "star.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notSeen: return .fireLightGray
        case .seen:    return .fireBlue
        case .caught:  return .fireOrange
        case .evolved: return .fireGreen
        }
    }

    var next: PokemonStatus {
        PokemonStatus(rawValue: (self.rawValue + 1) % 4) ?? .notSeen
    }
}

// MARK: - Pokemon Entry

struct PokemonEntry: Identifiable {
    let id: Int // dex number
    let name: String
    let types: [PokemonType]
    let stats: PokemonStats
    let location: String
    let description: String

    var dexString: String {
        String(format: "#%03d", id)
    }

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

// MARK: - Full Kanto Pokédex

struct PokedexData {
    static let kanto: [PokemonEntry] = [
        PokemonEntry(id: 1, name: "Bulbasaur", types: [.grass, .poison], stats: PokemonStats(hp: 45, attack: 49, defense: 49, spAttack: 65, spDefense: 65, speed: 45), location: "Pueblo Paleta (inicial)", description: "Pokémon planta semilla con poderes especiales."),
        PokemonEntry(id: 2, name: "Ivysaur", types: [.grass, .poison], stats: PokemonStats(hp: 60, attack: 62, defense: 63, spAttack: 80, spDefense: 80, speed: 60), location: "Evolucionar Bulbasaur", description: "Evolución de Bulbasaur con capullo floreciente."),
        PokemonEntry(id: 3, name: "Venusaur", types: [.grass, .poison], stats: PokemonStats(hp: 80, attack: 82, defense: 83, spAttack: 100, spDefense: 100, speed: 80), location: "Evolucionar Ivysaur", description: "Flor gigante con poderes destructivos imensos."),
        PokemonEntry(id: 4, name: "Charmander", types: [.fire], stats: PokemonStats(hp: 39, attack: 52, defense: 43, spAttack: 60, spDefense: 50, speed: 65), location: "Pueblo Paleta (inicial)", description: "Pequeño dragón lagartija con cola en llamas."),
        PokemonEntry(id: 5, name: "Charmeleon", types: [.fire], stats: PokemonStats(hp: 58, attack: 64, defense: 58, spAttack: 80, spDefense: 65, speed: 80), location: "Evolucionar Charmander", description: "Réptil fuego con cuerno en la cabeza."),
        PokemonEntry(id: 6, name: "Charizard", types: [.fire, .flying], stats: PokemonStats(hp: 78, attack: 84, defense: 78, spAttack: 109, spDefense: 85, speed: 100), location: "Evolucionar Charmeleon", description: "Dragón volador de fuego supremo y poder."),
        PokemonEntry(id: 7, name: "Squirtle", types: [.water], stats: PokemonStats(hp: 44, attack: 48, defense: 65, spAttack: 50, spDefense: 64, speed: 43), location: "Pueblo Paleta (inicial)", description: "Tortuga de agua dentro de caparazón duro."),
        PokemonEntry(id: 8, name: "Wartortle", types: [.water], stats: PokemonStats(hp: 59, attack: 63, defense: 80, spAttack: 65, spDefense: 80, speed: 58), location: "Evolucionar Squirtle", description: "Tortuga con orejas esponjosas y agua fría."),
        PokemonEntry(id: 9, name: "Blastoise", types: [.water], stats: PokemonStats(hp: 79, attack: 83, defense: 100, spAttack: 85, spDefense: 105, speed: 78), location: "Evolucionar Wartortle", description: "Tortuga artillería con cañones de agua."),
        PokemonEntry(id: 10, name: "Caterpie", types: [.bug], stats: PokemonStats(hp: 45, attack: 30, defense: 35, spAttack: 20, spDefense: 20, speed: 45), location: "Ruta 2, Bosque Viridian", description: "Oruga pequeña que come hojas sin parar."),
        PokemonEntry(id: 11, name: "Metapod", types: [.bug], stats: PokemonStats(hp: 50, attack: 20, defense: 55, spAttack: 25, spDefense: 25, speed: 30), location: "Ruta 1, Ruta 2", description: "Capullo duro protegido de insecto."),
        PokemonEntry(id: 12, name: "Butterfree", types: [.bug, .flying], stats: PokemonStats(hp: 60, attack: 45, defense: 50, spAttack: 90, spDefense: 80, speed: 70), location: "Evolucionar Metapod", description: "Mariposa violeta voladora y venenosa."),
        PokemonEntry(id: 13, name: "Weedle", types: [.bug, .poison], stats: PokemonStats(hp: 40, attack: 35, defense: 30, spAttack: 20, spDefense: 20, speed: 50), location: "Ruta 1, Bosque Verde", description: "Gusano pequeño venenoso con púa."),
        PokemonEntry(id: 14, name: "Kakuna", types: [.bug, .poison], stats: PokemonStats(hp: 45, attack: 25, defense: 50, spAttack: 25, spDefense: 25, speed: 35), location: "Bosque Verde", description: "Capullo dorado que es inmóvil."),
        PokemonEntry(id: 15, name: "Beedrill", types: [.bug, .poison], stats: PokemonStats(hp: 65, attack: 90, defense: 40, spAttack: 45, spDefense: 80, speed: 75), location: "Evolucionar Kakuna", description: "Abeja violeta armada con púas venenosas."),
        PokemonEntry(id: 16, name: "Pidgey", types: [.normal, .flying], stats: PokemonStats(hp: 40, attack: 45, defense: 40, spAttack: 35, spDefense: 35, speed: 56), location: "Ruta 1, Ruta 2", description: "Avecilla común voladora abundante."),
        PokemonEntry(id: 17, name: "Pidgeotto", types: [.normal, .flying], stats: PokemonStats(hp: 63, attack: 60, defense: 55, spAttack: 50, spDefense: 50, speed: 71), location: "Ruta 5, Ruta 6", description: "Pájaro intermedio ágil y voraz."),
        PokemonEntry(id: 18, name: "Pidgeot", types: [.normal, .flying], stats: PokemonStats(hp: 83, attack: 80, defense: 75, spAttack: 70, spDefense: 70, speed: 91), location: "Evolucionar Pidgeotto", description: "Águila majestuosa voladora suprema."),
        PokemonEntry(id: 19, name: "Rattata", types: [.normal], stats: PokemonStats(hp: 30, attack: 56, defense: 35, spAttack: 25, spDefense: 35, speed: 72), location: "Ruta 1, Ruta 3", description: "Rata ágil roedor caminante común."),
        PokemonEntry(id: 20, name: "Raticate", types: [.normal], stats: PokemonStats(hp: 55, attack: 81, defense: 60, spAttack: 50, spDefense: 70, speed: 97), location: "Evolucionar Rattata", description: "Rata gigante mordaz y territorial."),
        PokemonEntry(id: 21, name: "Spearow", types: [.normal, .flying], stats: PokemonStats(hp: 40, attack: 60, defense: 30, spAttack: 31, spDefense: 31, speed: 70), location: "Ruta 3, Ruta 4", description: "Pájaro pequeño voraz y agresivo."),
        PokemonEntry(id: 22, name: "Fearow", types: [.normal, .flying], stats: PokemonStats(hp: 65, attack: 90, defense: 65, spAttack: 61, spDefense: 61, speed: 100), location: "Evolucionar Spearow", description: "Halcón grande cazador de presas rápidas."),
        PokemonEntry(id: 23, name: "Ekans", types: [.poison], stats: PokemonStats(hp: 35, attack: 60, defense: 44, spAttack: 40, spDefense: 54, speed: 55), location: "Ruta 4, Ruta 8", description: "Serpiente venenosa reptil escupidora."),
        PokemonEntry(id: 24, name: "Arbok", types: [.poison], stats: PokemonStats(hp: 60, attack: 95, defense: 69, spAttack: 65, spDefense: 79, speed: 80), location: "Evolucionar Ekans", description: "Cobra grande capaz escupidor venenoso."),
        PokemonEntry(id: 25, name: "Pikachu", types: [.electric], stats: PokemonStats(hp: 35, attack: 55, defense: 40, spAttack: 50, spDefense: 50, speed: 90), location: "Ruta 2, Bosque Verde", description: "Ratón eléctrico emblemático descarga fulgor."),
        PokemonEntry(id: 26, name: "Raichu", types: [.electric], stats: PokemonStats(hp: 60, attack: 90, defense: 55, spAttack: 90, spDefense: 80, speed: 110), location: "Evolucionar Pikachu", description: "Rata eléctrica gigante poder devastador."),
        PokemonEntry(id: 27, name: "Sandshrew", types: [.ground], stats: PokemonStats(hp: 50, attack: 75, defense: 85, spAttack: 20, spDefense: 30, speed: 40), location: "Ruta 3, Ruta 4", description: "Topo terrestre excavador con garras."),
        PokemonEntry(id: 28, name: "Sandslash", types: [.ground], stats: PokemonStats(hp: 75, attack: 100, defense: 110, spAttack: 45, spDefense: 55, speed: 65), location: "Evolucionar Sandshrew", description: "Topo gigante armado pinchos tierra."),
        PokemonEntry(id: 29, name: "Nidoran♀", types: [.poison], stats: PokemonStats(hp: 55, attack: 47, defense: 52, spAttack: 40, spDefense: 40, speed: 41), location: "Ruta 3, Ruta 4", description: "Pequeña hembra venenosa de púas."),
        PokemonEntry(id: 30, name: "Nidorina", types: [.poison], stats: PokemonStats(hp: 70, attack: 62, defense: 67, spAttack: 55, spDefense: 55, speed: 56), location: "Evolucionar Nidoran♀", description: "Hembra intermedia venenosa defensiva."),
        PokemonEntry(id: 31, name: "Nidoqueen", types: [.poison, .ground], stats: PokemonStats(hp: 90, attack: 92, defense: 87, spAttack: 75, spDefense: 85, speed: 76), location: "Evolucionar Nidorina", description: "Reina venenosa subterránea devastadora."),
        PokemonEntry(id: 32, name: "Nidoran♂", types: [.poison], stats: PokemonStats(hp: 46, attack: 57, defense: 40, spAttack: 40, spDefense: 40, speed: 50), location: "Ruta 3, Ruta 4", description: "Pequeño macho venenoso cornudo."),
        PokemonEntry(id: 33, name: "Nidorino", types: [.poison], stats: PokemonStats(hp: 61, attack: 72, defense: 55, spAttack: 55, spDefense: 55, speed: 65), location: "Evolucionar Nidoran♂", description: "Macho intermedio venenoso fuerte."),
        PokemonEntry(id: 34, name: "Nidoking", types: [.poison, .ground], stats: PokemonStats(hp: 81, attack: 102, defense: 77, spAttack: 85, spDefense: 75, speed: 85), location: "Evolucionar Nidorino", description: "Rey venenoso subterráneo poderoso."),
        PokemonEntry(id: 35, name: "Clefairy", types: [.normal], stats: PokemonStats(hp: 70, attack: 73, defense: 60, spAttack: 73, spDefense: 60, speed: 35), location: "Cueva Luna", description: "Hada lunar de poderes mágicos."),
        PokemonEntry(id: 36, name: "Clefable", types: [.normal], stats: PokemonStats(hp: 95, attack: 70, defense: 73, spAttack: 60, spDefense: 73, speed: 60), location: "Evolucionar Clefairy", description: "Hada encantadora de magia suprema."),
        PokemonEntry(id: 37, name: "Vulpix", types: [.fire], stats: PokemonStats(hp: 38, attack: 41, defense: 40, spAttack: 50, spDefense: 65, speed: 65), location: "Ruta 7, Ruta 8", description: "Zorro pequeño de seis colas ardientes."),
        PokemonEntry(id: 38, name: "Ninetales", types: [.fire], stats: PokemonStats(hp: 73, attack: 76, defense: 75, spAttack: 81, spDefense: 100, speed: 100), location: "Evolucionar Vulpix", description: "Zorro antiguo nueve colas fuego."),
        PokemonEntry(id: 39, name: "Jigglypuff", types: [.normal], stats: PokemonStats(hp: 115, attack: 40, defense: 20, spAttack: 45, spDefense: 25, speed: 20), location: "Ruta 5, Ruta 6, Ruta 7, Ruta 8", description: "Globo rosa cantante adormilador."),
        PokemonEntry(id: 40, name: "Wigglytuff", types: [.normal], stats: PokemonStats(hp: 140, attack: 70, defense: 45, spAttack: 75, spDefense: 50, speed: 45), location: "Evolucionar Jigglypuff", description: "Bola gigante cantante sedante."),
        PokemonEntry(id: 41, name: "Zubat", types: [.poison, .flying], stats: PokemonStats(hp: 40, attack: 45, defense: 35, spAttack: 30, spDefense: 40, speed: 55), location: "Cueva Celeste, Cueva Pokémon", description: "Murciélago pequeño venenoso ciego."),
        PokemonEntry(id: 42, name: "Golbat", types: [.poison, .flying], stats: PokemonStats(hp: 75, attack: 80, defense: 75, spAttack: 70, spDefense: 75, speed: 90), location: "Evolucionar Zubat", description: "Murciélago gigante chupasangre oscuro."),
        PokemonEntry(id: 43, name: "Oddish", types: [.grass, .poison], stats: PokemonStats(hp: 45, attack: 50, defense: 55, spAttack: 75, spDefense: 65, speed: 30), location: "Ruta 1, Ruta 5, Ruta 6", description: "Monstruo planta pequeño raro venenoso."),
        PokemonEntry(id: 44, name: "Gloom", types: [.grass, .poison], stats: PokemonStats(hp: 60, attack: 65, defense: 70, spAttack: 85, spDefense: 75, speed: 40), location: "Evolucionar Oddish", description: "Flor intermedia maloliente venenosa."),
        PokemonEntry(id: 45, name: "Vileplume", types: [.grass, .poison], stats: PokemonStats(hp: 75, attack: 80, defense: 85, spAttack: 100, spDefense: 90, speed: 50), location: "Evolucionar Gloom", description: "Flor gigante aromática venenosa."),
        PokemonEntry(id: 46, name: "Paras", types: [.bug, .grass], stats: PokemonStats(hp: 35, attack: 70, defense: 55, spAttack: 55, spDefense: 55, speed: 25), location: "Bosque Verde, Ruta 2", description: "Araña pequeña con setas hongo."),
        PokemonEntry(id: 47, name: "Parasect", types: [.bug, .grass], stats: PokemonStats(hp: 60, attack: 95, defense: 80, spAttack: 60, spDefense: 80, speed: 30), location: "Evolucionar Paras", description: "Araña gigante dominada por hongo."),
        PokemonEntry(id: 48, name: "Venonat", types: [.bug, .poison], stats: PokemonStats(hp: 60, attack: 55, defense: 50, spAttack: 40, spDefense: 55, speed: 45), location: "Bosque Verde", description: "Insecto pequeño venenoso nocturno."),
        PokemonEntry(id: 49, name: "Venomoth", types: [.bug, .poison], stats: PokemonStats(hp: 70, attack: 65, defense: 60, spAttack: 90, spDefense: 75, speed: 90), location: "Evolucionar Venonat", description: "Mariposa venenosa polvos tóxicos."),
        PokemonEntry(id: 50, name: "Diglett", types: [.ground], stats: PokemonStats(hp: 10, attack: 55, defense: 25, spAttack: 35, spDefense: 45, speed: 95), location: "Ruta 2, Ruta 11", description: "Topo pequeño subterráneo escondido."),
        PokemonEntry(id: 51, name: "Dugtrio", types: [.ground], stats: PokemonStats(hp: 35, attack: 80, defense: 50, spAttack: 50, spDefense: 70, speed: 120), location: "Evolucionar Diglett", description: "Trío topos subterráneos rápidos."),
        PokemonEntry(id: 52, name: "Meowth", types: [.normal], stats: PokemonStats(hp: 40, attack: 45, defense: 35, spAttack: 40, spDefense: 40, speed: 90), location: "Ruta 5, Ruta 6, Ruta 7, Ruta 8", description: "Gato pequeño voraz moneda dorada."),
        PokemonEntry(id: 53, name: "Persian", types: [.normal], stats: PokemonStats(hp: 65, attack: 70, defense: 60, spAttack: 65, spDefense: 65, speed: 115), location: "Evolucionar Meowth", description: "Gato noble ágil cazador refinado."),
        PokemonEntry(id: 54, name: "Psyduck", types: [.water], stats: PokemonStats(hp: 50, attack: 52, defense: 48, spAttack: 65, spDefense: 50, speed: 55), location: "Ruta 5, Ruta 6, Ruta 8", description: "Pato confundido psíquico raro."),
        PokemonEntry(id: 55, name: "Golduck", types: [.water], stats: PokemonStats(hp: 80, attack: 82, defense: 78, spAttack: 95, spDefense: 80, speed: 85), location: "Evolucionar Psyduck", description: "Pato inteligente poderoso psíquico."),
        PokemonEntry(id: 56, name: "Mankey", types: [.fighting], stats: PokemonStats(hp: 40, attack: 80, defense: 35, spAttack: 35, spDefense: 35, speed: 70), location: "Ruta 3, Ruta 4", description: "Mono pequeño agresivo puños rápidos."),
        PokemonEntry(id: 57, name: "Primeape", types: [.fighting], stats: PokemonStats(hp: 65, attack: 105, defense: 60, spAttack: 60, spDefense: 60, speed: 95), location: "Evolucionar Mankey", description: "Mono furioso golpeador devastador."),
        PokemonEntry(id: 58, name: "Growlithe", types: [.fire], stats: PokemonStats(hp: 55, attack: 70, defense: 45, spAttack: 70, spDefense: 50, speed: 60), location: "Ruta 7, Ruta 8", description: "Cachorro fogoso leal guardia."),
        PokemonEntry(id: 59, name: "Arcanine", types: [.fire], stats: PokemonStats(hp: 90, attack: 110, defense: 80, spAttack: 100, spDefense: 80, speed: 95), location: "Evolucionar Growlithe", description: "Perro legendario fuego majestuoso."),
        PokemonEntry(id: 60, name: "Poliwag", types: [.water], stats: PokemonStats(hp: 40, attack: 50, defense: 40, spAttack: 40, spDefense: 40, speed: 90), location: "Ruta 5, Ruta 6, Ruta 8", description: "Renacuajo acuático ondulante simple."),
        PokemonEntry(id: 61, name: "Poliwhirl", types: [.water], stats: PokemonStats(hp: 65, attack: 65, defense: 65, spAttack: 80, spDefense: 80, speed: 90), location: "Evolucionar Poliwag", description: "Renacuajo espiral acuático intermedio."),
        PokemonEntry(id: 62, name: "Poliwrath", types: [.water, .fighting], stats: PokemonStats(hp: 90, attack: 95, defense: 95, spAttack: 70, spDefense: 90, speed: 70), location: "Evolucionar Poliwhirl", description: "Rana azul campeona lucha acuática."),
        PokemonEntry(id: 63, name: "Abra", types: [.psychic], stats: PokemonStats(hp: 25, attack: 20, defense: 15, spAttack: 105, spDefense: 55, speed: 90), location: "Ruta 7, Ruta 8", description: "Mago teletransportador desaparece."),
        PokemonEntry(id: 64, name: "Kadabra", types: [.psychic], stats: PokemonStats(hp: 40, attack: 35, defense: 30, spAttack: 120, spDefense: 70, speed: 105), location: "Evolucionar Abra", description: "Mago psíquico inteligencia sobrenatural."),
        PokemonEntry(id: 65, name: "Alakazam", types: [.psychic], stats: PokemonStats(hp: 55, attack: 50, defense: 45, spAttack: 135, spDefense: 85, speed: 120), location: "Evolucionar Kadabra", description: "Genio psíquico poder mental supremo."),
        PokemonEntry(id: 66, name: "Machop", types: [.fighting], stats: PokemonStats(hp: 70, attack: 80, defense: 50, spAttack: 35, spDefense: 35, speed: 35), location: "Ruta 3, Ruta 4", description: "Luchador pequeño músculos entrenados."),
        PokemonEntry(id: 67, name: "Machoke", types: [.fighting], stats: PokemonStats(hp: 80, attack: 100, defense: 70, spAttack: 50, spDefense: 60, speed: 45), location: "Evolucionar Machop", description: "Luchador intermedio fuerza bruta."),
        PokemonEntry(id: 68, name: "Machamp", types: [.fighting], stats: PokemonStats(hp: 90, attack: 130, defense: 80, spAttack: 65, spDefense: 85, speed: 55), location: "Evolucionar Machoke", description: "Titán cuatro brazos poder absoluto."),
        PokemonEntry(id: 69, name: "Bellsprout", types: [.grass, .poison], stats: PokemonStats(hp: 50, attack: 75, defense: 35, spAttack: 70, spDefense: 30, speed: 40), location: "Ruta 5, Ruta 6", description: "Planta pequeña venenosa látigo."),
        PokemonEntry(id: 70, name: "Weepinbell", types: [.grass, .poison], stats: PokemonStats(hp: 65, attack: 90, defense: 50, spAttack: 85, spDefense: 45, speed: 55), location: "Evolucionar Bellsprout", description: "Trampa venenosa carnívora intermedia."),
        PokemonEntry(id: 71, name: "Victreebel", types: [.grass, .poison], stats: PokemonStats(hp: 80, attack: 105, defense: 65, spAttack: 100, spDefense: 70, speed: 70), location: "Evolucionar Weepinbell", description: "Planta gigante carnívora insaciable."),
        PokemonEntry(id: 72, name: "Tentacool", types: [.water, .poison], stats: PokemonStats(hp: 40, attack: 40, defense: 35, spAttack: 50, spDefense: 100, speed: 70), location: "Ruta 5, Ruta 6", description: "Medusa pequeña tentáculos venenosos."),
        PokemonEntry(id: 73, name: "Tentacruel", types: [.water, .poison], stats: PokemonStats(hp: 80, attack: 70, defense: 65, spAttack: 80, spDefense: 120, speed: 100), location: "Evolucionar Tentacool", description: "Medusa gigante tentáculos poderosos."),
        PokemonEntry(id: 74, name: "Geodude", types: [.rock, .ground], stats: PokemonStats(hp: 40, attack: 80, defense: 100, spAttack: 30, spDefense: 30, speed: 20), location: "Ruta 3, Ruta 4, Cueva Pokémon", description: "Roca levitante pequeña viviente."),
        PokemonEntry(id: 75, name: "Graveler", types: [.rock, .ground], stats: PokemonStats(hp: 55, attack: 95, defense: 115, spAttack: 45, spDefense: 45, speed: 35), location: "Evolucionar Geodude", description: "Roca rodante intermedia pesada."),
        PokemonEntry(id: 76, name: "Golem", types: [.rock, .ground], stats: PokemonStats(hp: 80, attack: 120, defense: 130, spAttack: 55, spDefense: 65, speed: 45), location: "Evolucionar Graveler", description: "Fortaleza rocosa defensa impenetrable."),
        PokemonEntry(id: 77, name: "Ponyta", types: [.fire], stats: PokemonStats(hp: 50, attack: 85, defense: 55, spAttack: 65, spDefense: 55, speed: 90), location: "Ruta 7, Ruta 8", description: "Caballo pequeño crines flameantes."),
        PokemonEntry(id: 78, name: "Rapidash", types: [.fire], stats: PokemonStats(hp: 65, attack: 100, defense: 70, spAttack: 80, spDefense: 70, speed: 105), location: "Evolucionar Ponyta", description: "Centauro fuego velocidad galopante."),
        PokemonEntry(id: 79, name: "Slowpoke", types: [.water, .psychic], stats: PokemonStats(hp: 90, attack: 65, defense: 65, spAttack: 40, spDefense: 40, speed: 15), location: "Ruta 5, Ruta 6, Ruta 8", description: "Pez simple tardío muy confundido."),
        PokemonEntry(id: 80, name: "Slowbro", types: [.water, .psychic], stats: PokemonStats(hp: 95, attack: 75, defense: 110, spAttack: 100, spDefense: 80, speed: 30), location: "Evolucionar Slowpoke", description: "Caballito marino psíquico con cangrejo."),
        PokemonEntry(id: 81, name: "Magnemite", types: [.electric, .steel], stats: PokemonStats(hp: 25, attack: 35, defense: 70, spAttack: 95, spDefense: 55, speed: 45), location: "Ruta 5, Ruta 6", description: "Imán eléctrico pequeño flotante."),
        PokemonEntry(id: 82, name: "Magneton", types: [.electric, .steel], stats: PokemonStats(hp: 50, attack: 60, defense: 95, spAttack: 120, spDefense: 70, speed: 70), location: "Evolucionar Magnemite", description: "Trío imanes eléctricos unidos."),
        PokemonEntry(id: 83, name: "Farfetch'd", types: [.normal, .flying], stats: PokemonStats(hp: 52, attack: 90, defense: 55, spAttack: 58, spDefense: 62, speed: 60), location: "Ruta 12, Ruta 13", description: "Pato extraño espada verdura."),
        PokemonEntry(id: 84, name: "Doduo", types: [.normal, .flying], stats: PokemonStats(hp: 35, attack: 85, defense: 45, spAttack: 35, spDefense: 35, speed: 75), location: "Ruta 12, Ruta 13", description: "Ave dos cabezas corriente rápida."),
        PokemonEntry(id: 85, name: "Dodrio", types: [.normal, .flying], stats: PokemonStats(hp: 60, attack: 110, defense: 70, spAttack: 60, spDefense: 60, speed: 100), location: "Evolucionar Doduo", description: "Ave tres cabezas voladora suprema."),
        PokemonEntry(id: 86, name: "Seel", types: [.water], stats: PokemonStats(hp: 65, attack: 45, defense: 55, spAttack: 45, spDefense: 70, speed: 45), location: "Ruta 16, Ruta 17", description: "Foca marina hielo adorable."),
        PokemonEntry(id: 87, name: "Dewgong", types: [.water, .ice], stats: PokemonStats(hp: 90, attack: 70, defense: 80, spAttack: 70, spDefense: 95, speed: 70), location: "Evolucionar Seel", description: "Foca hielo elegancia nieve marina."),
        PokemonEntry(id: 88, name: "Grimer", types: [.poison], stats: PokemonStats(hp: 80, attack: 80, defense: 50, spAttack: 40, spDefense: 50, speed: 25), location: "Ruta 11, Cueva Pokémon", description: "Lodo venenoso repugnante putrefacto."),
        PokemonEntry(id: 89, name: "Muk", types: [.poison], stats: PokemonStats(hp: 105, attack: 105, defense: 75, spAttack: 65, spDefense: 100, speed: 50), location: "Evolucionar Grimer", description: "Montaña lodo tóxico infeccioso."),
        PokemonEntry(id: 90, name: "Shellder", types: [.water], stats: PokemonStats(hp: 30, attack: 65, defense: 100, spAttack: 45, spDefense: 25, speed: 40), location: "Ruta 10, Ruta 11", description: "Ostra cerrada defensa impenetrable."),
        PokemonEntry(id: 91, name: "Cloyster", types: [.water, .ice], stats: PokemonStats(hp: 50, attack: 95, defense: 180, spAttack: 85, spDefense: 45, speed: 70), location: "Evolucionar Shellder", description: "Ostra acorazada hielo defensor."),
        PokemonEntry(id: 92, name: "Gastly", types: [.ghost, .poison], stats: PokemonStats(hp: 30, attack: 35, defense: 30, spAttack: 100, spDefense: 35, speed: 80), location: "Casa Pokémon, Mansión Fantasma", description: "Fantasma gaseoso espectro venenoso."),
        PokemonEntry(id: 93, name: "Haunter", types: [.ghost, .poison], stats: PokemonStats(hp: 45, attack: 50, defense: 45, spAttack: 115, spDefense: 55, speed: 95), location: "Evolucionar Gastly", description: "Espíritu flotante congelador tóxico."),
        PokemonEntry(id: 94, name: "Gengar", types: [.ghost, .poison], stats: PokemonStats(hp: 60, attack: 65, defense: 60, spAttack: 130, spDefense: 75, speed: 110), location: "Evolucionar Haunter", description: "Sombra demoníaca poder paranormal."),
        PokemonEntry(id: 95, name: "Onix", types: [.rock, .ground], stats: PokemonStats(hp: 35, attack: 45, defense: 160, spAttack: 30, spDefense: 45, speed: 70), location: "Cueva Celeste, Cueva Pokémon", description: "Serpiente roca segmentada defensa."),
        PokemonEntry(id: 96, name: "Drowzee", types: [.psychic], stats: PokemonStats(hp: 60, attack: 48, defense: 45, spAttack: 43, spDefense: 90, speed: 42), location: "Ruta 12, Ruta 13", description: "Comedor sueños psíquico pesadilla."),
        PokemonEntry(id: 97, name: "Hypno", types: [.psychic], stats: PokemonStats(hp: 85, attack: 73, defense: 70, spAttack: 73, spDefense: 115, speed: 67), location: "Evolucionar Drowzee", description: "Hipnotizador psíquico ensalmo profundo."),
        PokemonEntry(id: 98, name: "Krabby", types: [.water], stats: PokemonStats(hp: 30, attack: 105, defense: 90, spAttack: 25, spDefense: 25, speed: 50), location: "Ruta 10, Ruta 11", description: "Cangrejo pequeño pinzas afiladas."),
        PokemonEntry(id: 99, name: "Kingler", types: [.water], stats: PokemonStats(hp: 55, attack: 130, defense: 115, spAttack: 50, spDefense: 50, speed: 75), location: "Evolucionar Krabby", description: "Cangrejo gigante pinzas devastadoras."),
        PokemonEntry(id: 100, name: "Voltorb", types: [.electric], stats: PokemonStats(hp: 40, attack: 30, defense: 50, spAttack: 55, spDefense: 55, speed: 100), location: "Centro Pokémon (Silph Co.)", description: "Esfera eléctrica flotante explosiva."),
        PokemonEntry(id: 101, name: "Electrode", types: [.electric], stats: PokemonStats(hp: 60, attack: 50, defense: 70, spAttack: 80, spDefense: 80, speed: 150), location: "Evolucionar Voltorb", description: "Proyectil eléctrico velocidad máxima."),
        PokemonEntry(id: 102, name: "Exeggcute", types: [.grass, .psychic], stats: PokemonStats(hp: 60, attack: 40, defense: 80, spAttack: 60, spDefense: 45, speed: 40), location: "Ruta 6, Ruta 14", description: "Seis huevos psíquicos conectados."),
        PokemonEntry(id: 103, name: "Exeggutor", types: [.grass, .psychic], stats: PokemonStats(hp: 95, attack: 95, defense: 85, spAttack: 125, spDefense: 75, speed: 55), location: "Evolucionar Exeggcute", description: "Palmera tres cabezas psíquica."),
        PokemonEntry(id: 104, name: "Cubone", types: [.ground], stats: PokemonStats(hp: 50, attack: 75, defense: 95, spAttack: 40, spDefense: 50, speed: 35), location: "Ruta 10", description: "Óseo pequeño calavera madre."),
        PokemonEntry(id: 105, name: "Marowak", types: [.ground], stats: PokemonStats(hp: 75, attack: 100, defense: 110, spAttack: 50, spDefense: 80, speed: 45), location: "Evolucionar Cubone", description: "Guerrero óseo defensa ancestral."),
        PokemonEntry(id: 106, name: "Hitmonlee", types: [.fighting], stats: PokemonStats(hp: 50, attack: 120, defense: 53, spAttack: 35, spDefense: 110, speed: 87), location: "Casino de Celadon (regalo)", description: "Luchador patadas devastadoras precisas."),
        PokemonEntry(id: 107, name: "Hitmonchan", types: [.fighting], stats: PokemonStats(hp: 50, attack: 105, defense: 79, spAttack: 35, spDefense: 110, speed: 76), location: "Casino de Celadon (regalo)", description: "Boxeador puñetazo fuego combinado."),
        PokemonEntry(id: 108, name: "Lickitung", types: [.normal], stats: PokemonStats(hp: 90, attack: 55, defense: 75, spAttack: 60, spDefense: 75, speed: 30), location: "Ruta 14", description: "Lengua rosa pegajosa enrollante."),
        PokemonEntry(id: 109, name: "Koffing", types: [.poison], stats: PokemonStats(hp: 40, attack: 65, defense: 95, spAttack: 60, spDefense: 45, speed: 35), location: "Ruta 8, Ruta 24", description: "Bola humo tóxica flotante peligrosa."),
        PokemonEntry(id: 110, name: "Weezing", types: [.poison], stats: PokemonStats(hp: 65, attack: 90, defense: 120, spAttack: 85, spDefense: 70, speed: 60), location: "Evolucionar Koffing", description: "Pareja humo tóxico explosiva."),
        PokemonEntry(id: 111, name: "Rhyhorn", types: [.ground, .rock], stats: PokemonStats(hp: 80, attack: 90, defense: 65, spAttack: 30, spDefense: 30, speed: 40), location: "Ruta 14, Ruta 15", description: "Rinoceronte primordial carga fuerte."),
        PokemonEntry(id: 112, name: "Rhydon", types: [.ground, .rock], stats: PokemonStats(hp: 105, attack: 130, defense: 100, spAttack: 55, spDefense: 60, speed: 40), location: "Evolucionar Rhyhorn", description: "Titán rinoceronte defensa piedra."),
        PokemonEntry(id: 113, name: "Chansey", types: [.normal], stats: PokemonStats(hp: 250, attack: 5, defense: 5, spAttack: 35, spDefense: 105, speed: 30), location: "Ruta 15, Ruta 16", description: "Huevo sagrado cuidador amigable."),
        PokemonEntry(id: 114, name: "Tangela", types: [.grass], stats: PokemonStats(hp: 65, attack: 55, defense: 115, spAttack: 100, spDefense: 40, speed: 60), location: "Ruta 14", description: "Enredadera verde defensa viva."),
        PokemonEntry(id: 115, name: "Kangaskhan", types: [.normal], stats: PokemonStats(hp: 105, attack: 95, defense: 80, spAttack: 40, spDefense: 80, speed: 90), location: "Ruta 15, Ruta 16", description: "Marsupial madre protectora cría."),
        PokemonEntry(id: 116, name: "Horsea", types: [.water], stats: PokemonStats(hp: 30, attack: 40, defense: 70, spAttack: 70, spDefense: 25, speed: 60), location: "Ruta 12, Ruta 13", description: "Caballito marino pequeño tinta."),
        PokemonEntry(id: 117, name: "Seadra", types: [.water], stats: PokemonStats(hp: 55, attack: 65, defense: 95, spAttack: 95, spDefense: 45, speed: 85), location: "Evolucionar Horsea", description: "Dragón marino espinas venenosas."),
        PokemonEntry(id: 118, name: "Goldeen", types: [.water], stats: PokemonStats(hp: 45, attack: 67, defense: 60, spAttack: 35, spDefense: 50, speed: 63), location: "Ruta 6, Ruta 12, Ruta 13", description: "Pez dorado aletas bailarín."),
        PokemonEntry(id: 119, name: "Seaking", types: [.water], stats: PokemonStats(hp: 80, attack: 92, defense: 65, spAttack: 65, spDefense: 80, speed: 68), location: "Evolucionar Goldeen", description: "Rey pez rojo poderoso territorial."),
        PokemonEntry(id: 120, name: "Staryu", types: [.water], stats: PokemonStats(hp: 30, attack: 45, defense: 55, spAttack: 70, spDefense: 55, speed: 85), location: "Ruta 5, Ruta 6", description: "Estrella marina común regeneradora."),
        PokemonEntry(id: 121, name: "Starmie", types: [.water, .psychic], stats: PokemonStats(hp: 60, attack: 75, defense: 85, spAttack: 100, spDefense: 85, speed: 115), location: "Evolucionar Staryu", description: "Joya psíquica marina brillante."),
        PokemonEntry(id: 122, name: "Mr. Mime", types: [.psychic], stats: PokemonStats(hp: 40, attack: 45, defense: 65, spAttack: 100, spDefense: 120, speed: 90), location: "Silph Co. (regalo)", description: "Mimo psíquico ilusión invisible muro."),
        PokemonEntry(id: 123, name: "Scyther", types: [.bug, .flying], stats: PokemonStats(hp: 70, attack: 110, defense: 80, spAttack: 55, spDefense: 80, speed: 105), location: "Ruta 14", description: "Mantis insecto segadores metálicos."),
        PokemonEntry(id: 124, name: "Jynx", types: [.ice, .psychic], stats: PokemonStats(hp: 65, attack: 50, defense: 35, spAttack: 115, spDefense: 95, speed: 95), location: "Ruta 17", description: "Humanoides hielo psíquica sedutora."),
        PokemonEntry(id: 125, name: "Electabuzz", types: [.electric], stats: PokemonStats(hp: 65, attack: 83, defense: 57, spAttack: 95, spDefense: 85, speed: 105), location: "Ruta 11", description: "Titán eléctrico puños rayos."),
        PokemonEntry(id: 126, name: "Magmar", types: [.fire], stats: PokemonStats(hp: 65, attack: 95, defense: 57, spAttack: 100, spDefense: 85, speed: 93), location: "Casa Pokémon", description: "Titán fuego aliento magma ardiente."),
        PokemonEntry(id: 127, name: "Pinsir", types: [.bug], stats: PokemonStats(hp: 65, attack: 125, defense: 100, spAttack: 55, spDefense: 70, speed: 85), location: "Ruta 14", description: "Ciervo insecto tenazas mortales."),
        PokemonEntry(id: 128, name: "Tauros", types: [.normal], stats: PokemonStats(hp: 75, attack: 100, defense: 95, spAttack: 40, spDefense: 70, speed: 110), location: "Ruta 16, Ruta 17", description: "Toro salvaje cuernos embestidor."),
        PokemonEntry(id: 129, name: "Magikarp", types: [.water], stats: PokemonStats(hp: 20, attack: 10, defense: 55, spAttack: 15, spDefense: 20, speed: 80), location: "Ruta 5, Ruta 6", description: "Pez rojo inútil débil saltarín."),
        PokemonEntry(id: 130, name: "Gyarados", types: [.water, .flying], stats: PokemonStats(hp: 95, attack: 125, defense: 79, spAttack: 60, spDefense: 100, speed: 81), location: "Evolucionar Magikarp", description: "Dragón acuático destructor cataclismo."),
        PokemonEntry(id: 131, name: "Lapras", types: [.water, .ice], stats: PokemonStats(hp: 130, attack: 85, defense: 80, spAttack: 85, spDefense: 95, speed: 60), location: "Ruta 19, Ruta 20", description: "Transportista hielo suave legendaria."),
        PokemonEntry(id: 132, name: "Ditto", types: [.normal], stats: PokemonStats(hp: 48, attack: 48, defense: 48, spAttack: 48, spDefense: 48, speed: 48), location: "Cueva Pokémon", description: "Blob rosado imitador transformista."),
        PokemonEntry(id: 133, name: "Eevee", types: [.normal], stats: PokemonStats(hp: 55, attack: 55, defense: 50, spAttack: 45, spDefense: 65, speed: 55), location: "Silph Co. (regalo)", description: "Evolución versátil mutante potencial."),
        PokemonEntry(id: 134, name: "Vaporeon", types: [.water], stats: PokemonStats(hp: 130, attack: 65, defense: 60, spAttack: 110, spDefense: 95, speed: 65), location: "Evolucionar Eevee", description: "Aleta agua resistencia acuática."),
        PokemonEntry(id: 135, name: "Jolteon", types: [.electric], stats: PokemonStats(hp: 65, attack: 65, defense: 60, spAttack: 110, spDefense: 95, speed: 130), location: "Evolucionar Eevee", description: "Rayo eléctrico velocidad absoluta."),
        PokemonEntry(id: 136, name: "Flareon", types: [.fire], stats: PokemonStats(hp: 65, attack: 130, defense: 60, spAttack: 95, spDefense: 110, speed: 65), location: "Evolucionar Eevee", description: "Llama ardiente ataque devastador."),
        PokemonEntry(id: 137, name: "Porygon", types: [.normal], stats: PokemonStats(hp: 65, attack: 60, defense: 70, spAttack: 85, spDefense: 75, speed: 40), location: "Game Corner (monedas)", description: "Pokémon artificial virtual digital."),
        PokemonEntry(id: 138, name: "Omanyte", types: [.rock, .water], stats: PokemonStats(hp: 35, attack: 40, defense: 100, spAttack: 90, spDefense: 55, speed: 35), location: "Fósil de laboratorio", description: "Cefalópodo antiguo tentáculos fósil."),
        PokemonEntry(id: 139, name: "Omastar", types: [.rock, .water], stats: PokemonStats(hp: 70, attack: 60, defense: 125, spAttack: 115, spDefense: 70, speed: 55), location: "Evolucionar Omanyte", description: "Monstruo antiguo tentáculos mortales."),
        PokemonEntry(id: 140, name: "Kabuto", types: [.rock, .water], stats: PokemonStats(hp: 30, attack: 80, defense: 90, spAttack: 55, spDefense: 45, speed: 55), location: "Fósil de laboratorio", description: "Trilobites antiguo caparazón fósil."),
        PokemonEntry(id: 141, name: "Kabutops", types: [.rock, .water], stats: PokemonStats(hp: 60, attack: 115, defense: 105, spAttack: 65, spDefense: 75, speed: 80), location: "Evolucionar Kabuto", description: "Depredador antiguo segadores mortales."),
        PokemonEntry(id: 142, name: "Aerodactyl", types: [.rock, .flying], stats: PokemonStats(hp: 80, attack: 105, defense: 65, spAttack: 60, spDefense: 75, speed: 130), location: "Fósil de laboratorio", description: "Pterodáctilo antiguo alas velocidad."),
        PokemonEntry(id: 143, name: "Snorlax", types: [.normal], stats: PokemonStats(hp: 150, attack: 80, defense: 100, spAttack: 40, spDefense: 65, speed: 30), location: "Ruta 12, Ruta 16", description: "Gigante dormilón comilón soñador."),
        PokemonEntry(id: 144, name: "Articuno", types: [.ice, .flying], stats: PokemonStats(hp: 90, attack: 85, defense: 100, spAttack: 95, spDefense: 125, speed: 85), location: "Cueva Celeste", description: "Ave hielo legendaria inmortal."),
        PokemonEntry(id: 145, name: "Zapdos", types: [.electric, .flying], stats: PokemonStats(hp: 90, attack: 90, defense: 85, spAttack: 125, spDefense: 90, speed: 100), location: "Central Eléctrica", description: "Ave rayo legendaria relámpago."),
        PokemonEntry(id: 146, name: "Moltres", types: [.fire, .flying], stats: PokemonStats(hp: 90, attack: 100, defense: 90, spAttack: 125, spDefense: 85, speed: 90), location: "Montaña Fuego", description: "Ave fuego legendaria reencarnación."),
        PokemonEntry(id: 147, name: "Dratini", types: [.dragon], stats: PokemonStats(hp: 41, attack: 64, defense: 45, spAttack: 50, spDefense: 50, speed: 50), location: "Ruta 10, Game Corner", description: "Dragoncillo pequeño serpiente agua."),
        PokemonEntry(id: 148, name: "Dragonair", types: [.dragon], stats: PokemonStats(hp: 61, attack: 84, defense: 65, spAttack: 70, spDefense: 70, speed: 70), location: "Evolucionar Dratini", description: "Dragón intermedio elegante flotador."),
        PokemonEntry(id: 149, name: "Dragonite", types: [.dragon, .flying], stats: PokemonStats(hp: 91, attack: 134, defense: 95, spAttack: 100, spDefense: 100, speed: 80), location: "Evolucionar Dragonair", description: "Dragón supremo poder destructivo."),
        PokemonEntry(id: 150, name: "Mewtwo", types: [.psychic], stats: PokemonStats(hp: 106, attack: 110, defense: 90, spAttack: 154, spDefense: 90, speed: 130), location: "Cueva de Mewtwo", description: "Clon psíquico poder genético supremo."),
        PokemonEntry(id: 151, name: "Mew", types: [.psychic], stats: PokemonStats(hp: 100, attack: 100, defense: 100, spAttack: 100, spDefense: 100, speed: 100), location: "Evento especial", description: "Pokémon ancestral legendario sagrado."),
    ]
}
