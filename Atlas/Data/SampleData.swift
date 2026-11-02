import Foundation

/// Sample New York data for slice 1, matching the prototype. Notes are placeholders.
struct SampleData {
    let me = Person(id: Person.meID, name: "You", colorIndex: 0, isMe: true)

    let friends = [
        Person(id: "allison", name: "Allison", colorIndex: 0, isFullAccess: true),
        Person(id: "emma", name: "Emma", colorIndex: 1),
        Person(id: "nick", name: "Nick", colorIndex: 2),
    ]

    let places: [Place] = [
        Place(id: "lilia", name: "Lilia", detail: "Restaurant · Williamsburg · handmade pasta", category: .dinner, latitude: 40.7177, longitude: -73.9523, tags: ["Dinner", "Italian"]),
        Place(id: "devocion", name: "Devoción", detail: "Coffee shop · Williamsburg", category: .coffee, latitude: 40.7163, longitude: -73.9645, tags: ["Coffee"]),
        Place(id: "domino", name: "Domino Park", detail: "Park · Williamsburg waterfront", category: .park, latitude: 40.7144, longitude: -73.9681, tags: ["Parks"]),
        Place(id: "lindustrie", name: "L\u{2019}Industrie Pizzeria", detail: "Pizzeria · Williamsburg", category: .dinner, latitude: 40.7116, longitude: -73.9578, tags: ["Dinner", "Pizza"]),
        Place(id: "russ", name: "Russ & Daughters", detail: "Appetizing shop · Lower East Side", category: .coffee, latitude: 40.7224, longitude: -73.9884, tags: ["Breakfast"]),
        Place(id: "katz", name: "Katz\u{2019}s Delicatessen", detail: "Deli · Lower East Side", category: .dinner, latitude: 40.7223, longitude: -73.9874, tags: ["Dinner"]),
        Place(id: "met", name: "The Met", detail: "Museum · Upper East Side", category: .museum, latitude: 40.7794, longitude: -73.9632, tags: ["Museums"]),
        Place(id: "viacarota", name: "Via Carota", detail: "Restaurant · West Village · Italian", category: .dinner, latitude: 40.7334, longitude: -74.0036, tags: ["Dinner", "Italian"]),
        Place(id: "whitney", name: "Whitney Museum", detail: "Museum · Meatpacking District", category: .museum, latitude: 40.7396, longitude: -74.0089, tags: ["Museums"]),
        Place(id: "moma", name: "MoMA", detail: "Museum · Midtown", category: .museum, latitude: 40.7614, longitude: -73.9776, tags: ["Museums"]),
        Place(id: "bkmuseum", name: "Brooklyn Museum", detail: "Museum · Prospect Heights", category: .museum, latitude: 40.6712, longitude: -73.9636, tags: ["Museums"]),
        Place(id: "luger", name: "Peter Luger", detail: "Steakhouse · Williamsburg", category: .dinner, latitude: 40.7099, longitude: -73.9622, tags: ["Dinner"]),
        Place(id: "sunday", name: "Sunday in Brooklyn", detail: "Restaurant · Williamsburg · brunch", category: .dinner, latitude: 40.7146, longitude: -73.9656, tags: ["Brunch"]),
        Place(id: "lucien", name: "Lucien", detail: "French bistro · East Village", category: .dinner, latitude: 40.7240, longitude: -73.9844, tags: ["Dinner"]),
        Place(id: "tenement", name: "Tenement Museum", detail: "Museum · Lower East Side", category: .museum, latitude: 40.7188, longitude: -73.9900, tags: ["Museums"]),
        Place(id: "ledive", name: "Le Dive", detail: "Wine bar · Lower East Side", category: .bar, latitude: 40.7149, longitude: -73.9913, tags: ["Bars"]),
    ]

    let takes: [String: [Take]] = [
        "lilia": [Take(personID: Person.meID, rating: 5, note: "Get the mafaldini. Book 30 days out."), Take(personID: "nick", rating: 4.5, note: "Sit at the bar if you walk in.")],
        "devocion": [Take(personID: Person.meID, rating: 4, note: "Big skylight, good for working.")],
        "domino": [Take(personID: Person.meID, rating: 4, note: "Sunset over the bridge."), Take(personID: "emma", rating: 4)],
        "lindustrie": [Take(personID: Person.meID, rating: 4.5, note: "The burrata slice."), Take(personID: "nick", rating: 5, note: "Best slice in the city.")],
        "russ": [Take(personID: Person.meID, rating: 4), Take(personID: "allison", rating: 4.5, note: "Get the Super Heebster.")],
        "katz": [Take(personID: Person.meID, rating: 0), Take(personID: "allison", rating: 4, note: "Pastrami on rye. Keep your ticket.")],
        "met": [Take(personID: Person.meID, rating: 5, note: "The roof in summer."), Take(personID: "emma", rating: 5, note: "Temple of Dendur right before closing.")],
        "viacarota": [Take(personID: "allison", rating: 5, note: "Cacio e pepe and the green salad.")],
        "whitney": [Take(personID: "allison", rating: 4, note: "The terraces are the best part.")],
        "moma": [Take(personID: "emma", rating: 4)],
        "bkmuseum": [Take(personID: "emma", rating: 4.5, note: "First Saturdays are free.")],
        "luger": [Take(personID: "nick", rating: 4, note: "Order the thick-cut bacon.")],
        "sunday": [Take(personID: "nick", rating: 2, note: "Long wait, not worth it.")],
    ]

    var incoming: [IncomingMap] {
        [
            IncomingMap(
                id: "allison-downtown",
                fromID: "allison",
                title: "Dinner and museums downtown",
                placeIDs: ["viacarota", "whitney", "russ", "katz", "lucien", "tenement", "ledive"],
                takes: [
                    "viacarota": Take(personID: "allison", rating: 5, note: "Cacio e pepe and the green salad."),
                    "whitney": Take(personID: "allison", rating: 4, note: "The terraces are the best part."),
                    "russ": Take(personID: "allison", rating: 4.5, note: "Get the Super Heebster."),
                    "katz": Take(personID: "allison", rating: 4, note: "Pastrami on rye. Keep your ticket."),
                    "lucien": Take(personID: "allison", rating: 4.5, note: "Steak frites and a bottle of red."),
                    "tenement": Take(personID: "allison", rating: 5, note: "Book the walking tour, not just the apartments."),
                    "ledive": Take(personID: "allison", rating: 4, note: "Go after dinner and sit outside."),
                ],
                sentAt: Date().addingTimeInterval(-2 * 3600),
                isNew: true
            )
        ]
    }
}
