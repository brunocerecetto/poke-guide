//
//  GameData.swift
//  poke guide
//
//  Todos los datos estáticos de la guía.
//

import Foundation

// MARK: - Models

struct Gym: Identifiable {
    let id = UUID()
    let name: String
    let leader: String
    let levelRange: String
    let note: String
    let badge: String
}

struct TeamMember: Identifiable {
    let id = UUID()
    let name: String
    let moves: [String]
    let notes: String
    let emoji: String
}

struct Capture: Identifiable {
    let id = UUID()
    let pokemon: String
    let location: String
    let note: String
}

struct HMEntry: Identifiable {
    let id = UUID()
    let hm: String
    let pokemon: String
    let location: String
}

struct TMEntry: Identifiable {
    let id = UUID()
    let tm: String
    let target: String
    let origin: String
}

struct Tip: Identifiable {
    let id = UUID()
    let pokemon: String
    let rule: String
}

struct EliteMember: Identifiable {
    let id = UUID()
    let name: String
    let strategy: String
    let levels: String
}

struct RouteStep: Identifiable {
    let id: String
    let text: String
}

struct RouteSection: Identifiable {
    let id = UUID()
    let title: String
    let steps: [RouteStep]
}

// MARK: - Static Data

struct GameData {

    static let gyms: [Gym] = [
        Gym(name: "Pewter", leader: "Brock", levelRange: "12–14", note: "Bubble/Bubblebeam basta", badge: "🪨"),
        Gym(name: "Cerulean", leader: "Misty", levelRange: "20–22", note: "Wartortle/Blastoise estable; TM03 Water Pulse", badge: "💧"),
        Gym(name: "Vermilion", leader: "Lt. Surge", levelRange: "24–26", note: "Dig lo tumba solo; TM34 Shock Wave", badge: "⚡"),
        Gym(name: "Celadon", leader: "Erika", levelRange: "29–31", note: "Premio TM19 Giga Drain", badge: "🌿"),
        Gym(name: "Fuchsia", leader: "Koga", levelRange: "43–45", note: "Surf, Dig y Psychic moves", badge: "☠️"),
        Gym(name: "Saffron", leader: "Sabrina", levelRange: "43–45", note: "Snorlax absorbe; Exeggutor entra bien", badge: "🔮"),
        Gym(name: "Cinnabar", leader: "Blaine", levelRange: "47–49", note: "Blastoise lo pasa por arriba", badge: "🔥"),
        Gym(name: "Viridian", leader: "Giovanni", levelRange: "46–48", note: "TM26 Earthquake → Nidoking", badge: "🌍"),
    ]

    static let team: [TeamMember] = [
        TeamMember(name: "Blastoise", moves: ["Surf", "Ice Beam", "Bite", "Protect / Strength"], notes: "Tu starter y tanque Water/Ice. Squirtle aprende Bubble 7, Water Gun 13, Bite 18, Protect 28. Evoluciona a Wartortle 16, Blastoise 36. Surf reemplaza Water Gun como STAB principal. Ice Beam (TM13, 4.000 monedas) es crítico para Lance. Bite cubre Ghost/Psychic. Usuario fijo de HM Surf.", emoji: "🐢"),
        TeamMember(name: "Nidoking", moves: ["Earthquake", "Brick Break", "Dig", "Strength / Return"], notes: "Versatilidad total. Nidoran♂ Route 3 → Double Kick 12 → Nidorino 16 → Horn Attack 22 → Moon Stone → Nidoking. Dig (TM28, gratis) sostiene todo el mid game. Earthquake (TM26, premio Giovanni) es tu nuke Ground de endgame. Brick Break (TM31, SS Anne) para Normal/Ice. Coverage insano: Ground/Fighting/Poison.", emoji: "🦏"),
        TeamMember(name: "Jolteon", moves: ["Thunderbolt", "Double Kick", "Dig", "Strength / Aerial Ace"], notes: "El más rápido del equipo (130 Speed base). Eevee gratis en Celadon Mansion nv 25 → Thunder Stone inmediato → Jolteon. Viene con ThunderShock, Quick Attack. Aprende Double Kick al 30. Thunderbolt (TM24, 4.000 monedas) es PRIORIDAD #1 de compra. Clave contra Lorelei, Gyarados de Lance y Blue.", emoji: "⚡"),
        TeamMember(name: "Arcanine", moves: ["Flamethrower", "Bite", "Dig", "Strength / Aerial Ace"], notes: "Growlithe Route 7 (FireRed exclusivo). Ya viene con Bite. Aprende Flame Wheel 31, Flamethrower 49. Si comprás TM35 Flamethrower (4.000 monedas): Fire Stone ya y enseñarle TM. Si NO comprás TM35: esperar a nv 31 para Flame Wheel, después Fire Stone. Stats sólidas (110 Atk, 100 SpAtk, 95 Speed).", emoji: "🐕‍🦺"),
        TeamMember(name: "Snorlax", moves: ["Body Slam", "Yawn", "Rest", "Strength / Shadow Ball"], notes: "Captura en Route 12 o 16 con Poké Flute. Nv 30. Tanque defensivo bruto (160 HP, 110 SpDef). Aprende Yawn, Rest y Body Slam por nivel — no necesita TMs para funcionar. Shadow Ball (TM30, 4.500 monedas) es upgrade de lujo para coverage Ghost. Clave contra Agatha. Rest + Yawn es combo defensivo letal.", emoji: "😴"),
        TeamMember(name: "Exeggutor", moves: ["Psychic", "Giga Drain", "Sleep Powder", "Stun Spore"], notes: "Exeggcute en Safari Zone. Timeline clave: Confusion 19, Stun Spore 25, Sleep Powder 37. ¡NO evolucionar antes del 37! Después de Sleep Powder: Leaf Stone → Exeggutor. Enseñar TM29 Psychic (gratis Saffron) y TM19 Giga Drain (premio Erika). Sleep Powder + Psychic + Giga Drain es más consistente que Solar Beam.", emoji: "🌴"),
    ]

    static let captures: [Capture] = [
        Capture(pokemon: "Nidoran♂", location: "Route 3", note: "Core desde temprano"),
        Capture(pokemon: "Growlithe", location: "Route 7", note: "FireRed exclusivo"),
        Capture(pokemon: "Eevee", location: "Celadon Mansion", note: "Regalo nv25 → Jolteon"),
        Capture(pokemon: "Exeggcute", location: "Safari Zone", note: "Entrenar sin piedra hasta 37"),
        Capture(pokemon: "Snorlax", location: "Route 12 o 16", note: "Guardar antes, capturar uno"),
    ]

    static let hms: [HMEntry] = [
        HMEntry(hm: "Surf", pokemon: "Blastoise (fijo)", location: "Safari Zone"),
        HMEntry(hm: "Strength", pokemon: "Snorlax / Nidoking", location: "Warden (Gold Teeth)"),
        HMEntry(hm: "Cut", pokemon: "Slot temporal", location: "SS Anne"),
        HMEntry(hm: "Fly", pokemon: "Slot temporal", location: "Route 16"),
        HMEntry(hm: "Flash", pokemon: "Opcional", location: "Aide de Oak (10 spp)"),
        HMEntry(hm: "Rock Smash", pokemon: "Postgame", location: "Sevii Islands"),
        HMEntry(hm: "Waterfall", pokemon: "Postgame", location: "Sevii Islands"),
    ]

    static let tms: [TMEntry] = [
        TMEntry(tm: "TM24 Thunderbolt", target: "Jolteon", origin: "4.000 monedas"),
        TMEntry(tm: "TM13 Ice Beam", target: "Blastoise", origin: "4.000 monedas"),
        TMEntry(tm: "TM35 Flamethrower", target: "Arcanine", origin: "4.000 mon. (después de TB+IB)"),
        TMEntry(tm: "TM29 Psychic", target: "Exeggutor", origin: "Gratis en Saffron"),
        TMEntry(tm: "TM19 Giga Drain", target: "Exeggutor", origin: "Premio de Erika"),
        TMEntry(tm: "TM26 Earthquake", target: "Nidoking", origin: "Premio de Giovanni"),
        TMEntry(tm: "TM31 Brick Break", target: "Nidoking / Snorlax", origin: "SS Anne / Celadon"),
        TMEntry(tm: "TM30 Shadow Ball", target: "Snorlax", origin: "4.500 mon. (lujo)"),
    ]

    static let tips: [Tip] = [
        Tip(pokemon: "⚡ Jolteon", rule: "No gastes TM24 Thunderbolt fuera de Jolteon. Es tu STAB eléctrico principal y con 130 Speed outspeeds casi todo el juego. Thunderbolt es la compra #1 del Game Corner."),
        Tip(pokemon: "🐢 Blastoise", rule: "No gastes TM13 Ice Beam fuera de Blastoise. Ice Beam es CRÍTICO para Lance: one-shotea Dragonairs y Dragonite. Sin Ice Beam dependés de Blizzard (70% accuracy) y la Liga se complica."),
        Tip(pokemon: "🐕‍🦺 Growlithe", rule: "Si NO vas a comprar TM35 Flamethrower: no evolucionar antes de nv 31 para asegurar Flame Wheel. Arcanine no aprende moves por nivel. Si SÍ comprás TM35: usá Fire Stone cuando quieras y enseñale Flamethrower."),
        Tip(pokemon: "🦏 Nidorino", rule: "No uses Moon Stone antes de Horn Attack (nv 22). Nidoking no aprende moves por nivel. Double Kick 12 y Horn Attack 22 son la ventana óptima. Después de Moon Stone, vivís de TMs (Dig, Earthquake, Brick Break)."),
        Tip(pokemon: "🌴 Exeggcute", rule: "No uses Leaf Stone antes de Sleep Powder (nv 37). Exeggutor NO aprende moves por nivel. Confusion 19 → Stun Spore 25 → Sleep Powder 37 → Leaf Stone. Sleep Powder es el move que lo hace viable en la Liga."),
        Tip(pokemon: "⚡ Eevee → Jolteon", rule: "Evolucioná con Thunder Stone en cuanto lo recibís en Celadon. Los moves de Eevee no te sirven. Enseñale TM34 Shock Wave enseguida como STAB temporal hasta que compres Thunderbolt."),
        Tip(pokemon: "💰 Dinero", rule: "Vas a necesitar ~$250,000 para monedas del Game Corner si comprás las 3 TMs. Peleá contra todos los trainers que puedas. Usá Amulet Coin si lo conseguís. VS Seeker (post-Vermilion) te deja repelear trainers."),
        Tip(pokemon: "🎒 Items clave", rule: "No vendas: Moon Stone (Nidoking), Fire Stone (Arcanine), Thunder Stone (Jolteon), Leaf Stone (Exeggutor), Poké Flute (Snorlax), Silph Scope (Pokémon Tower), Master Ball (guardala para Mewtwo postgame)."),
    ]

    static let eliteFour: [EliteMember] = [
        EliteMember(name: "Lorelei", strategy: "Abrí con Jolteon → Thunderbolt a Dewgong (54), Cloyster (51), Slowbro (54) y Lapras (54). No regales a Jynx (51): es rápida y pega con Ice Punch. Cambiá a Arcanine o Nidoking para Jynx.", levels: "51–54"),
        EliteMember(name: "Bruno", strategy: "Blastoise Surf destroza ambos Onix (51, 54). Para Hitmonchan (53), Hitmonlee (53) y Machamp (56): Exeggutor con Psychic los one-shotea si está sano. Si Exeggutor cayó, Blastoise resiste bien.", levels: "51–56"),
        EliteMember(name: "Agatha", strategy: "Snorlax es tu ancla — inmune a Ghost moves. Body Slam a Gengar (54, 58) y Haunter (53). Arbok (54) y Golbat (56) caen con Earthquake de Nidoking. Tené Awakenings para Hypnosis.", levels: "53–58"),
        EliteMember(name: "Lance", strategy: "Ice Beam con Blastoise es la clave: one-shotea Dragonairs (54, 54) y Dragonite (60). Jolteon Thunderbolt a Gyarados (56). Aerodactyl (58) cae con Ice Beam o Surf. Cuidado con Hyper Beam de Dragonite.", levels: "54–60"),
        EliteMember(name: "Blue", strategy: "Pidgeot 59: Jolteon Thunderbolt. Alakazam 57: Snorlax Body Slam (resiste Psychic). Rhydon 59: Blastoise Surf. Gyarados 59: Jolteon Thunderbolt. Arcanine 61: Blastoise Surf. Venusaur 63: Arcanine Flamethrower. Nidoking para limpiar lo que quede.", levels: "57–63"),
    ]

    static let preLeagueChecklist: [RouteStep] = [
        RouteStep(id: "pre1", text: "Blastoise con Surf + Ice Beam"),
        RouteStep(id: "pre2", text: "Nidoking con Earthquake"),
        RouteStep(id: "pre3", text: "Jolteon con Thunderbolt (no solo Shock Wave)"),
        RouteStep(id: "pre4", text: "Arcanine evolucionado con Flamethrower o Flame Wheel"),
        RouteStep(id: "pre5", text: "Snorlax capturado y con Body Slam + Rest"),
        RouteStep(id: "pre6", text: "Exeggutor con Sleep Powder + Psychic + Giga Drain"),
        RouteStep(id: "pre7", text: "Todos los pokémon nivel 52+ mínimo"),
        RouteStep(id: "pre8", text: "15–20 Hyper Potions o Full Restores"),
        RouteStep(id: "pre9", text: "10+ Revives"),
        RouteStep(id: "pre10", text: "Full Heals o Awakenings para Agatha"),
        RouteStep(id: "pre11", text: "Guardado afuera del Indigo Plateau"),
    ]

    static let postgame: [RouteStep] = [
        RouteStep(id: "post1", text: "Ir a Sevii Islands — One Island, hablar con Celio"),
        RouteStep(id: "post2", text: "Rock Smash en Kindle Road (One Island)"),
        RouteStep(id: "post3", text: "Waterfall en Icefall Cave (Four Island)"),
        RouteStep(id: "post4", text: "Completar la quest del Ruby y Sapphire para Celio"),
        RouteStep(id: "post5", text: "Desbloquear Cerulean Cave → capturar Mewtwo"),
        RouteStep(id: "post6", text: "Revancha Elite Four (equipos mejorados, nv 60+)"),
        RouteStep(id: "post7", text: "Completar Pokédex Nacional"),
    ]

    static let routeSections: [RouteSection] =
        [
            RouteSection(title: "1) Pallet Town → Pewter City", steps: [
                RouteStep(id: "r1a", text: "Elegir Squirtle como starter"),
                RouteStep(id: "r1b", text: "Rival fight 1: Squirtle Tackle spam, no hay ciencia"),
                RouteStep(id: "r1c", text: "Levelear Squirtle en Route 1 hasta nv 7–8 antes de ir a Viridian"),
                RouteStep(id: "r1d", text: "Comprar Poké Balls en Viridian (al menos 10)"),
                RouteStep(id: "r1e", text: "Entregar el paquete de Oak, recibir la Pokédex"),
                RouteStep(id: "r1f", text: "Route 2 → Viridian Forest: grindear contra Caterpie/Weedle hasta nv 12–13"),
                RouteStep(id: "r1g", text: "Squirtle aprende Bubble al 7 y Water Gun al 13"),
                RouteStep(id: "r1h", text: "No perder tiempo capturando pokémon extra — Squirtle solo basta"),
                RouteStep(id: "r1i", text: "⚔️ BROCK: Geodude 12 / Onix 14. Water Gun o Bubble destroza todo. Fácil."),
                RouteStep(id: "r1j", text: "Recibir TM39 Rock Tomb (no la necesitás)"),
            ]),
            RouteSection(title: "2) Pewter → Mt. Moon → Cerulean", steps: [
                RouteStep(id: "r2a", text: "Route 3: pelear contra todos los trainers para XP"),
                RouteStep(id: "r2b", text: "🔴 CAPTURA: Nidoran♂ en Route 3 (probabilidad ~15%). Este es tu futuro Nidoking."),
                RouteStep(id: "r2c", text: "Entrenar Nidoran♂ contra los trainers de Route 3 para ponerlo al día"),
                RouteStep(id: "r2d", text: "Entrar a Mt. Moon. Levantar items: Rare Candy, TM09 Bullet Seed, Star Piece"),
                RouteStep(id: "r2e", text: "🔴 IMPORTANTE: Agarrar al menos una Moon Stone (piso B2). ¡Guardarla para Nidorino!"),
                RouteStep(id: "r2f", text: "Derrotar al Super Nerd del fósil — elegir Helix o Dome (no importa para la run)"),
                RouteStep(id: "r2g", text: "Nidoran♂ aprende Double Kick al 12 — ya empieza a ser útil"),
                RouteStep(id: "r2h", text: "Salir de Mt. Moon. Curar en Cerulean City"),
                RouteStep(id: "r2i", text: "Rival fight 2 en Nugget Bridge: Squirtle/Wartortle lo maneja"),
                RouteStep(id: "r2j", text: "Nugget Bridge: pelear los 5 trainers + Rocket. Buena XP y $$$"),
                RouteStep(id: "r2k", text: "Ir a casa de Bill (Route 25). Ayudarlo → recibir el S.S. Ticket"),
                RouteStep(id: "r2l", text: "Squirtle debería evolucionar a Wartortle alrededor de nv 16"),
                RouteStep(id: "r2m", text: "⚔️ MISTY: Staryu 18 / Starmie 21. Wartortle con Bite (nv 18) es clave contra Starmie. Nidorino ayuda con Double Kick. Te da TM03 Water Pulse."),
            ]),
            RouteSection(title: "3) Cerulean → Vermilion City", steps: [
                RouteStep(id: "r3a", text: "Ir al norte de Cerulean (casa robada). Derrotar al Rocket Grunt"),
                RouteStep(id: "r3b", text: "🔴 RECOMPENSA: TM28 Dig — moveazo para mid game"),
                RouteStep(id: "r3c", text: "Nidoran♂ → Nidorino (nv 16). Esperar a Horn Attack al 22 antes de usar Moon Stone"),
                RouteStep(id: "r3d", text: "Una vez que Nidorino aprende Horn Attack 22: usar Moon Stone → Nidoking"),
                RouteStep(id: "r3e", text: "Enseñarle Dig a Nidoking inmediatamente. Dig será tu mejor move por un buen rato."),
                RouteStep(id: "r3f", text: "Route 5 → Underground Path → Route 6 → Vermilion City"),
                RouteStep(id: "r3g", text: "Ir al S.S. Anne. Pelear contra todos los trainers del barco (mucha XP)"),
                RouteStep(id: "r3h", text: "Rival fight 3 en el S.S. Anne"),
                RouteStep(id: "r3i", text: "🔴 ITEMS: Recibir HM01 Cut del capitán. Levantar TM31 Brick Break en el barco."),
                RouteStep(id: "r3j", text: "Enseñar Cut a un pokémon temporal (NO a tu core). Cortar el arbusto del gym."),
                RouteStep(id: "r3k", text: "⚔️ LT. SURGE: Voltorb 21 / Pikachu 18 / Raichu 24. Nidoking con Dig los destroza a todos. Pelea fácil."),
                RouteStep(id: "r3l", text: "Premio: TM34 Shock Wave. Guardarla para Jolteon más tarde."),
                RouteStep(id: "r3m", text: "Tip: el puzzle de las basuras — las llaves siempre están en basuras adyacentes"),
            ]),
            RouteSection(title: "4) Rock Tunnel → Lavender → Celadon", steps: [
                RouteStep(id: "r4a", text: "Route 9 hacia Rock Tunnel. Pelear trainers en el camino"),
                RouteStep(id: "r4b", text: "Opcional: volver a Route 2 y hablar con aide de Oak (10 pokémon registrados) → HM05 Flash"),
                RouteStep(id: "r4c", text: "Flash hace Rock Tunnel mucho más fácil. Sin Flash es jugable pero molesto."),
                RouteStep(id: "r4d", text: "Rock Tunnel: los trainers dan buena XP. Nidoking con Dig limpia casi todo."),
                RouteStep(id: "r4e", text: "Salir a Lavender Town. Por ahora no podés subir Pokémon Tower (necesitás Silph Scope)."),
                RouteStep(id: "r4f", text: "Ir por Route 8 → Underground Path → Route 7 hacia Celadon City"),
                RouteStep(id: "r4g", text: "🔴 CAPTURA: Growlithe en Route 7 (exclusivo de FireRed). Nivel ~18–20."),
                RouteStep(id: "r4h", text: "Celadon City: muchas cosas que hacer acá. Ir en este orden:"),
                RouteStep(id: "r4i", text: "1. Celadon Mansion (entrada trasera): subir al último piso → 🔴 Recibir Eevee nv 25"),
                RouteStep(id: "r4j", text: "2. Celadon Mansion planta baja: hablar con la señora → recibir Tea (abre las puertas de Saffron)"),
                RouteStep(id: "r4k", text: "3. Celadon Dept. Store: comprar Poké Dolls, pociones, y anotar precios de piedras"),
                RouteStep(id: "r4l", text: "4. Fire Stone ($2,100) para Growlithe. Thunder Stone ($2,100) para Eevee → Jolteon."),
                RouteStep(id: "r4m", text: "💰 Game Corner: si vas a comprar TMs con monedas, necesitás 12.000+ monedas en total"),
                RouteStep(id: "r4n", text: "💰 Podés comprar monedas: 50 monedas = $1,000. Para las 3 TMs clave = $240,000. O jugar las slots."),
                RouteStep(id: "r4o", text: "Rocket Hideout (debajo del Game Corner): limpiar los 4 pisos"),
                RouteStep(id: "r4p", text: "Piso B2: levantar Moon Stone (extra) y TM12 Taunt"),
                RouteStep(id: "r4q", text: "Piso B4: derrotar a Giovanni → recibir Silph Scope"),
                RouteStep(id: "r4r", text: "⚔️ ERIKA: Victreebel 29 / Tangela 24 / Vileplume 29. Arcanine o Growlithe con Bite/Ember barre. Si todavía no evolucionaste a Growlithe, Nidoking con Dig + Wartortle con Bite alcanzan."),
                RouteStep(id: "r4s", text: "Premio: TM19 Giga Drain → guardar para Exeggutor"),
            ]),
            RouteSection(title: "5) Evoluciones y Game Corner", steps: [
                RouteStep(id: "r5a", text: "DECISIÓN: Eevee → Jolteon. Usar Thunder Stone. Enseñarle Shock Wave (TM34) inmediatamente."),
                RouteStep(id: "r5b", text: "Jolteon aprende ThunderShock al nv 16 y Quick Attack al 23 (ya los tiene si evolucionás al 25)"),
                RouteStep(id: "r5c", text: "Jolteon aprende Double Kick al nv 30 — entrenalo para llegar"),
                RouteStep(id: "r5d", text: "DECISIÓN Growlithe: ¿vas a comprar TM35 Flamethrower?"),
                RouteStep(id: "r5e", text: "→ SÍ TM35: usá Fire Stone ahora → Arcanine, después le enseñás Flamethrower"),
                RouteStep(id: "r5f", text: "→ NO TM35: dejá Growlithe llegar a nv 31 (aprende Flame Wheel), DESPUÉS Fire Stone"),
                RouteStep(id: "r5g", text: "💰 COMPRAS Game Corner (Prize Exchange al oeste de Celadon):"),
                RouteStep(id: "r5h", text: "   1ro: TM24 Thunderbolt (4.000 monedas) → Jolteon [PRIORIDAD MÁXIMA]"),
                RouteStep(id: "r5i", text: "   2do: TM13 Ice Beam (4.000 monedas) → Blastoise"),
                RouteStep(id: "r5j", text: "   3ro: TM35 Flamethrower (4.000 monedas) → Arcanine [solo si te sobra]"),
                RouteStep(id: "r5k", text: "No comprar Shadow Ball todavía — 4.500 monedas y es lujo, no necesidad"),
            ]),
            RouteSection(title: "6) Pokémon Tower → Fuchsia City", steps: [
                RouteStep(id: "r6a", text: "Volver a Lavender Town con el Silph Scope"),
                RouteStep(id: "r6b", text: "Pokémon Tower: ahora podés identificar a los Gastly/Haunter/Cubone"),
                RouteStep(id: "r6c", text: "Los Channelers dan buena XP. Nidoking con Dig es super efectivo contra Ghost/Poison."),
                RouteStep(id: "r6d", text: "Rival fight 4 en el segundo piso de Pokémon Tower"),
                RouteStep(id: "r6e", text: "Piso 7: derrotar el fantasma Marowak (nv 30). No se puede capturar."),
                RouteStep(id: "r6f", text: "Rescatar a Mr. Fuji → recibir Poké Flute"),
                RouteStep(id: "r6g", text: "Con la Poké Flute podés despertar a los Snorlax. Hay dos: Route 12 y Route 16."),
                RouteStep(id: "r6h", text: "🔴 CAPTURA: Snorlax (nv 30). GUARDAR ANTES. Debilitalo con cuidado + Ultra Balls."),
                RouteStep(id: "r6i", text: "Tip: usá Sleep Powder/Stun Spore si tenés Exeggcute, o bájale la vida con ataques débiles"),
                RouteStep(id: "r6j", text: "Elegir ruta: Route 12 (sur, más trainers) o Route 16 (oeste, necesita Cut). Ambas llegan a Fuchsia."),
                RouteStep(id: "r6k", text: "Route 16: levantar HM02 Fly en la casa escondida (cortar arbusto). Enseñar a un HM slave."),
                RouteStep(id: "r6l", text: "Llegar a Fuchsia City. Ir directo a Safari Zone."),
                RouteStep(id: "r6m", text: "🔴 Safari Zone — 3 objetivos en una visita:"),
                RouteStep(id: "r6n", text: "   1. HM03 Surf (Secret House, zona más profunda)"),
                RouteStep(id: "r6o", text: "   2. Gold Teeth (zona 4, en el piso)"),
                RouteStep(id: "r6p", text: "   3. Capturar Exeggcute (aparece en todas las zonas, ~20% encounter)"),
                RouteStep(id: "r6q", text: "Tip Safari Zone: tirá Safari Balls sin debilitar. Bait/Rock cambian la catch rate pero es random."),
                RouteStep(id: "r6r", text: "Devolver Gold Teeth al Warden (casa al este de Fuchsia) → recibir HM04 Strength"),
                RouteStep(id: "r6s", text: "Enseñar Surf a Blastoise. Enseñar Strength a Snorlax o Nidoking."),
                RouteStep(id: "r6t", text: "🔴 Exeggcute: NO uses Leaf Stone todavía. Necesita Sleep Powder (nv 37)."),
                RouteStep(id: "r6u", text: "Exeggcute aprende: Confusion 19, Stun Spore 25, Sleep Powder 37. Evolucioná al 37."),
                RouteStep(id: "r6v", text: "⚔️ KOGA: Koffing 37 / Muk 39 / Koffing 37 / Weezing 43. Nidoking Earthquake barre. Blastoise Surf también. Cuidado con Self-Destruct."),
            ]),
            RouteSection(title: "7) Saffron City (Silph Co + Sabrina)", steps: [
                RouteStep(id: "r7a", text: "Con la Tea, entrar a Saffron City por cualquier puerta"),
                RouteStep(id: "r7b", text: "ANTES del Silph Co: ir a la casa de Mr. Psychic (al sur)"),
                RouteStep(id: "r7c", text: "🔴 Recibir TM29 Psychic GRATIS. Guardarla para Exeggutor."),
                RouteStep(id: "r7d", text: "Silph Co: 11 pisos. Muchos trainers = mucha XP."),
                RouteStep(id: "r7e", text: "Piso 5: levantar la Card Key (abre todas las puertas cerradas)"),
                RouteStep(id: "r7f", text: "Piso 7: recibir Lapras gratis del científico (backup Water/Ice si querés)"),
                RouteStep(id: "r7g", text: "Rival fight 5 en Silph Co. A esta altura tu equipo debería estar ~nv 35–40."),
                RouteStep(id: "r7h", text: "Piso 11: derrotar a Giovanni otra vez → recibir Master Ball"),
                RouteStep(id: "r7i", text: "🔴 MASTER BALL: guardarla. Podés usarla en Mewtwo postgame o en un legendary bird."),
                RouteStep(id: "r7j", text: "Ir al Saffron Gym. Los warp tiles son confusos — hay guías del orden correcto."),
                RouteStep(id: "r7k", text: "⚔️ SABRINA: Kadabra 38 / Mr. Mime 37 / Venomoth 38 / Alakazam 43. Snorlax es tu mejor opción (Body Slam, inmune a nada pero tanquea Psychic). Nidoking con Earthquake para Venomoth. Exeggutor resiste Psychic y puede Sleep Powder."),
            ]),
            RouteSection(title: "8) Cinnabar Island + Viridian Gym", steps: [
                RouteStep(id: "r8a", text: "Surfear desde Fuchsia (Route 19/20) o desde Pallet Town (Route 21) hacia Cinnabar"),
                RouteStep(id: "r8b", text: "Pokémon Mansion: necesitás la Secret Key para abrir el gym"),
                RouteStep(id: "r8c", text: "Pokémon Mansion: levantar TM14 Blizzard y TM22 Solar Beam"),
                RouteStep(id: "r8d", text: "TM22 Solar Beam es opción para Exeggutor (más power que Giga Drain pero 2 turnos)"),
                RouteStep(id: "r8e", text: "Para historia normal: Psychic + Giga Drain + Sleep Powder es más consistente"),
                RouteStep(id: "r8f", text: "⚔️ BLAINE: Growlithe 42 / Ponyta 40 / Rapidash 42 / Arcanine 47. Blastoise Surf arrasa todo. Pelea trivial."),
                RouteStep(id: "r8g", text: "Volar a Viridian City. El gym de Giovanni ahora está abierto."),
                RouteStep(id: "r8h", text: "⚔️ GIOVANNI: Rhyhorn 45 / Dugtrio 42 / Nidoqueen 44 / Nidoking 45 / Rhyhorn 50. Blastoise Surf/Ice Beam limpia. Exeggutor Giga Drain también es bueno."),
                RouteStep(id: "r8i", text: "🔴 Premio: TM26 Earthquake → enseñársela a Nidoking INMEDIATAMENTE"),
                RouteStep(id: "r8j", text: "Earthquake reemplaza a Dig como tu Ground nuke principal. Nidoking pasa a ser bestia."),
                RouteStep(id: "r8k", text: "Tu equipo final debería estar armado: Blastoise, Nidoking, Jolteon, Arcanine, Snorlax, Exeggutor"),
            ]),
            RouteSection(title: "9) Victory Road → Liga Pokémon", steps: [
                RouteStep(id: "r9a", text: "Route 22 (oeste de Viridian) → Rival fight 6. Último fight antes de la Liga."),
                RouteStep(id: "r9b", text: "Route 23: necesitás todas las 8 badges (los guards te frenan)"),
                RouteStep(id: "r9c", text: "Victory Road: necesitás Surf, Strength y posiblemente Rock Smash (no en FRLG, solo Strength)"),
                RouteStep(id: "r9d", text: "Mover los boulders con Strength para abrir camino. Hay Full Restore, TM37 Sandstorm, TM02 Dragon Claw."),
                RouteStep(id: "r9e", text: "TM02 Dragon Claw: no la necesitás para la run"),
                RouteStep(id: "r9f", text: "Si tu equipo está bajo de nivel, grindear en Victory Road (pokémon nv 40–48)"),
                RouteStep(id: "r9g", text: "Objetivo: todo el equipo nv 52+ antes de entrar a la Liga"),
                RouteStep(id: "r9h", text: "Indigo Plateau: Pokémon Center. Última chance de comprar items."),
                RouteStep(id: "r9i", text: "🔴 GUARDAR antes de entrar. Si perdés, volvés acá pero perdés la mitad de tu plata."),
                RouteStep(id: "r9j", text: "Verificar el Checklist Pre-Liga (sección Liga Pokémon) antes de entrar"),
            ]),
        ]
}
