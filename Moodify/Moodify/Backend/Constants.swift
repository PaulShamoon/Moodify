// Constants.swift
// Moodify
//
// Created by Paul Shamoon on 10/23/24.
//

//let sad_songs = [
//    // Seigfred
//    "1BViPjTT585XAhkUUrkts0",
//    // The Night We Met
//    "0QZ5yyl6B6utIWkxeBDxQN",
//    // The Scientist
//    "75JFxkI2RXiU7L9VXzMkle",
//    // Yellow
//    "3AJwUDP919kvQ9QcozQPxg",
//    // Space Song
//    "7H0ya83CMmgFcOhw0UB6ow",
//    // From the Dining Table
//    "1IF5UcqRO42D12vYwceOY6",
//    // White Ferrari
//    "2LMkwUfqC6S6s6qDVlEuzV",
//    // Echoes of Silence
//    "3weHnt82LuCTMa2AnZFM78",
//    // 2009
//    "6dFn6my1sHK2bcf23GlHwM",
//    // 28
//    "5iJKGpnFfvbjZJeAtwXfCj"
//]
//
//let happy_songs = [
//    // Happy
//    "60nZcImufyMA1MKQY3dcCH",
//    // As It Was
//    "4Dvkj6JhhA12EX05fT7y2e",
//    // Marry You
//    "6SKwQghsR8AISlxhcwyA9R",
//    // Safe and Sound
//    "6Z8R6UsFuGXGtiIxiD8ISb",
//    // Sugar
//    "2iuZJX9X9P0GKaE93xcPjk",
//    // Unwritten
//    "3U5JVgI2x4rDyHGObzJfNf",
//    // Brazil
//    "4sNG6zQBmtq7M8aeeKJRMQ",
//    // Pursuit of Happiness
//    "6MtKObWYda2qnNIpJI21uD",
//    // Viva la Vida
//    "1mea3bSkSGXuIRvnydlB5b",
//    // Teenage Dream
//    "5jzKL4BDMClWqRguW5qZvh"
//]
//
//let angry_songs = [
//    // heavy metal
//    // The Troopper
//    "2pxAohyJptQWTQ5ZRWYijN",
//    // Paranoid
//    "1jzDzZWeSDBg5fhNc3tczV",
//    // Killing In the Name
//    "59WN2psjkt1tyaxjspN8fp",
//    // Right Now
//    "437ShA8eBSfBmezIP9MeX1",
//
//    // pop punk
//    // Misery Business
//    "6SpLc7EXZIPpy0sVko0aoU",
//    // Still Into you
//    "1yjY7rpaAQvKwpdUliHx0d",
//
//    // hard rock
//    // Animals I Have Becom
//    "56sk7jBpZV0CD31G9hEU3b",
//    // I Hate Everything About You
//    "0M955bMOoilikPXwKLYpoi",
//
//    // Rap
//    // Imortal
//    "4IO8X9W69dIQe0EC5ALXhq",
//    // DNA
//    "6HZILIRieu8S0iqY8kIKhj"
//]
//
//let chill_songs = [
//    // Sweet Life
//    "6MEDfjHxnVNcYmHe3mM6L2",
//    // Cool Cat
//    "6Re2AwZUVlgBng04BZTauW",
//    // Chateau
//    "3vjs2MDHoF9xhylNg6Y9un",
//    // Linger
//    "2dono2Koz7DEvGwxUsmMLq",
//    // Stay
//    "4H7WNRErSbONkM06blBoGc",
//    // 505
//    "58ge6dfP91o9oXMzq3XkIS",
//    // For the First Time
//    "2R4AlwtrrkMaRKojcTIzmL",
//    // Dreams
//    "0ofHAoxe9vBkTCp2UQIavz",
//    // My Favorite Part
//    "66wkCYWlXzSTQAfnsPBptt",
//    // Mojo Pin
//    "3wBy12K7BHKHJspUwJw8fq"
//]


let angrySongs: [String: [String]] = [
    "classical": [],
    "country": [],
    "dance": [],
    "electronic": [
        // "Bangarang" by Skrillex ft. Sirah
        "6VRhkROS2SZHGlp0pxndbJ",
        // "Scary Monsters and Nice Sprites" by Skrillex
        "4rwpZEcnalkuhPyGkEdhu0",
        // "Animals" by Martin Garrix
        "0A9mHc7oYUoCECqByV8cQR",
        // "Get Low" by Dillon Francis & DJ Snake
        "3oZoXyU0SkDldgS7AcN4y4",
        // "Cannonball" by Showtek & Justin Prime
        "7zkVdBWAc2xMu0eyJTJfso",
        // "Toulouse" by Nicky Romero
        "2aJwlohnHuKWIUK8UntETK",
        // "Spaceman" by Hardwell
        "3Nnq6YSHQ5LwRKkioGIjhb",
        // "Core" by RL Grime
        "097ivRfD5gBHjqhwEMifOT",
        // "Ghosts 'n' Stuff" by deadmau5
        "3TljdWrXAgrEnyU00PM6CQ",
        // "Surface" by Aero Chord
        "5cDEB8LBAwNruEFGKgIZBX"
    ],
    "hip-hop": [
        // "HUMBLE." by Kendrick Lamar
        "7KXjTSCq5nL1LoYtL7XAwS",
        // "SICKO MODE" by Travis Scott
        "2xLMifQCjDGFmkHkpNLD9h",
        // "X Gon' Give It to Ya" by DMX
        "1zzxoZVylsna2BQB65Ppcb",
        // "Still D.R.E." by Dr. Dre ft. Snoop Dogg
        "503OTo2dSqe7qk76rgsbep",
        // "DNA." by Kendrick Lamar
        "6HZILIRieu8S0iqY8kIKhj",
        // "Power" by Kanye West
        "2gZUPNdnz5Y45eiGxpHGSc",
        // "B.O.B" by Outkast
        "3WibbMr6canxRJXhNtAvLU",
        // "Lose Yourself" by Eminem
        "5Z01UMMf7V1o0MzF86s6WJ",
        // "Forgot About Dre" by Dr. Dre ft. Eminem
        "7iXF2W9vKmDoGAhlHdpyIa",
        // "My Name Is" by Eminem
        "75IN3CtuZwTHTnZvYM4qnJ"
    ],
    "jazz": [
        // "Free Jazz" by Ornette Coleman
        "6V8P6r0oHuTorKcoDYN0mv",
        // "Chameleon" by Herbie Hancock
        "4Ce66JznW8QbeyTdSzdGwR",
        // "A Love Supreme Part II" by John Coltrane
        "7unF2ARDGldwWxZWCmlwDM",
        // "The Sidewinder" by Lee Morgan
        "0jGh2myWgeSSuj0bXeYZn0",
        // "Afro Blue" by Mongo Santamaria
        "7L92MWLFM6m3Ry1vCdthmj",
        // "Acknowledgement" by John Coltrane
        "65raJxFND8iynkiA5KkoHg",
        // "Passion Dance" by McCoy Tyner
        "0lELi5BqmUO4hXTFfAUf60",
        // "Manteca" by Dizzy Gillespie
        "6KpMB0Wgw1NVFqwn0DCprf",
        // "Salt Peanuts" by Charlie Parker
        "4YWv8mved9F2cnVkPD0AD3",
        // "Fire Waltz" by Eric Dolphy
        "1heuNsveTrbygNMoRgQSZk"
    ],
    "pop": [],
    "r&b": [],
    "rock": []
]

let chillSongs: [String: [String]] = [
    "classical": [],
    "country": [],
    "dance": [],
    "electronic": [
        // "Everything" by Diamond Pistols ft. Chase Martin
        "6WPTuvAWWhCG7WhvSy4qTp",
        // "Open" by Rhye
        "3JsA2sWDNR9oQogGAzqqtH",
        // "Eyes on Fire" by Blue Foundation
        "3XHrTm6WE2BOHafLwTT3GR",
        // "Intro" by The xx
        "5VfEuwErhx6X4eaPbyBfyu",
        // "Stay High" by Tove Lo (Habits Remix)
        "14OxJlLdcHNpgsm4DRwDOB",
        // "Coffee" by Sylvan Esso
        "30GGIrrJdSNtecPiFcVP5O",
        // "Night Owl" by Galimatias
        "5tuhOP6bY3NlwTHghY5MbN",
        // "Electric Feel" by MGMT
        "3FtYbEfBqAlGO46NUDQSAt",
        // "High" by Whethan ft. Dua Lipa
        "3dD9yyYTQ73SZvyOygyKva",
        // "All I Want" by Claptone
        "52rOdUPqn3k82Va08vvf2u"
    ],
    "hip-hop": [
        // "The Recipe" by Kendrick Lamar ft. Dr. Dre
        "1eRBW1HcyM1zPlxO26cScZ",
        // "Cigarette Daydreams" by Cage the Elephant
        "2tznHmp70DxMyr2XhWLOW0",
        // "Best Part" by Daniel Caesar ft. H.E.R.
        "1RMJOxR6GRPsBHL8qeC2ux",
        // "Crew" by GoldLink ft. Brent Faiyaz, Shy Glizzy
        "7E9xw8WQ6RLBkiD29gQ7kV",
        // "Location" by Khalid
        "152lZdxL1OR0ZMW6KquMif",
        // "Mango" by Kamauu ft. Adeline
        "1YUQTfkfLbQa5JuJVPH83h",
        // "Poetic Justice" by Kendrick Lamar ft. Drake
        "2P3SLxeQHPqh8qKB6gtJY2",
        // "How to Love" by Lil Wayne
        "5W7BcYDIaeXnpG3e39T7hJ",
        // "Find Your Wings" by Tyler, The Creator
        "7er0EUMY653mxZ1NVD9mwQ",
        // "Slow Down" by VanJess
        "7qXu5zUjLP4ZAP12QOZRX5"
    ],
    "jazz": [
        // "Blue in Green" by Miles Davis
        "0aWMVrwxPNYkKmFthzmpRi",
        // "My Funny Valentine" by Chet Baker
        "4l9hml2UCnxoNI3yCdL1BW",
        // "Autumn Leaves" by Bill Evans
        "7JtcCde09fsajDNHmPFrX7",
        // "Someday My Prince Will Come" by Dave Brubeck
        "0PHqHvmg4TIaANfbsvDMTR",
        // "Moanin'" by Charles Mingus
        "3rFzc8CLVDZ7OOtFa2jPYP",
        // "Georgia on My Mind" by Ray Charles
        "6yMGxqKj0218mFR5KqsMRq",
        // "Waltz for Debby" by Bill Evans
        "7bMrdOiYdHjz5dplqSxj8r",
        // "Pick Up the Sticks" by The Dave Brubeck Quartet
        "0XugQpP1aeQwpdGKHpjcci",
        // "Black Orpheus" by Vince Guaraldi
        "47IVfmEHcTDMBce0JVG6E9",
        // "In a Sentimental Mood" by Duke Ellington & John Coltrane
        "0E8q2Fx2XuzXCO2NSAppkR"
    ],
    "pop": [],
    "r&b": [],
    "rock": []
]

let happySongs: [String: [String]] = [
    "classical": [],
    "country": [],
    "dance": [],
    "electronic": [
        // "Lean On" by Major Lazer
        "01aTsQoKoeXofSTvKuunzv",
        // "Faded" by Alan Walker
        "7gHs73wELdeycvS48JfIos",
        // "Animals" by Martin Garrix
        "0A9mHc7oYUoCECqByV8cQR",
        // "Wake Me Up" by Avicii
        "0nrRP2bk19rLc0orkWPQk2",
        // "This Is What You Came For" by Calvin Harris
        "0azC730Exh71aQlOt9Zj3y",
        // "Titanium" by David Guetta
        "0lHAMNU8RGiIObScrsRgmP",
        // "Latch" by Disclosure
        "1DunhgeZSEgWiIYbHqXl0c",
        // "Closer" by The Chainsmokers
        "7BKLCZ1jbUBVqRi2FVlTVw",
        // "Liquid Spirit" by Claptone
        "6wp5tGVNQYpKJPo1s3WUEY",
        // "Stay" by Zedd
        "2QtJA4gbwe1AcanB2p21aP"
    ],
    "hip-hop": [
        // "Can't Stop the Feeling!" by Justin Timberlake
        "1WkMMavIMc4JZ8cfMmxHkI",
        // "Uptown Funk" by Mark Ronson ft. Bruno Mars
        "32OlwWuMpZ6b0aN2RZOeMS",
        // "Happy" by Pharrell Williams
        "60nZcImufyMA1MKQY3dcCH",
        // "Good as Hell" by Lizzo
        "6KgBpzTuTRPebChN0VTyzV",
        // "Levitating" by Dua Lipa ft. DaBaby
        "5nujrmhLynf4yMoMtj8AQF",
        // "Sunflower" by Post Malone
        "3KkXRkHbMCARz0aVfEt68P",
        // "Blinding Lights" by The Weeknd
        "0VjIjW4GlUZAMYd2vXMi3b",
        // "Save Your Tears" by The Weeknd
        "5QO79kh1waicV47BqGRL3g",
        // "Peaches" by Justin Bieber
        "4iJyoBOLtHqaGxP12qzhQI",
        // "STAY" by The Kid LAROI & Justin Bieber
        "5HCyWlXZPP0y6Gqq8TgA20"
    ],
    "jazz": [
        // "Take Five" by Dave Brubeck
        "1YQWosTIljIvxAgHWTp7KP",
        // "Cheek to Cheek" by Ella Fitzgerald & Louis Armstrong
        "33jt3kYWjQzqn3xyYQ5ZEh",
        // "Fly Me to the Moon" by Frank Sinatra
        "7FXj7Qg3YorUxdrzvrcY25",
        // "Ain't Misbehavin'" by Fats Waller
        "3BFRqZFLSrqtQr6cjHbAxU",
        // "So What" by Miles Davis
        "4vLYewWIvqHfKtJDk8c8tq",
        // "In the Mood" by Glenn Miller
        "1xsY8IFXUrxeet1Fcmk4oC",
        // "Sing, Sing, Sing" by Benny Goodman
        "5L8ta4ECl5zeA6bGqY7G38",
        // "Electric Feel" by MGMT
        "3FtYbEfBqAlGO46NUDQSAt",
        // "Take Five" by Dave Brubeck
        "1YQWosTIljIvxAgHWTp7KP",
        // "My Favorite Things" by John Coltrane
        "3ZikLQCnH3SIswlGENBcKe"
    ],
    "pop": [],
    "r&b": [],
    "rock": []
]

let sadSongs: [String: [String]] = [
    "classical": [],
    "country": [],
    "dance": [],
    "electronic": [
        // "Shelter" by Porter Robinson & Madeon
        "2ewEh7LuvToYyGHq7yT8N1",
        // "Silhouettes" by Avicii
        "06h3McKzmxS8Bx58USHiMq",
        // "Ghosts 'n' Stuff" by deadmau5
        "3TljdWrXAgrEnyU00PM6CQ",
        // "Clarity" by Zedd ft. Foxes
        "60wwxj6Dd9NJlirf84wr2c",
        // "Strobe" by deadmau5
        "7IQDEmE7TaADP1EmlPxv3T",
        // "Faded" by Alan Walker
        "7gHs73wELdeycvS48JfIos",
        // "Stay" by Zedd & Alessia Cara
        "2QtJA4gbwe1AcanB2p21aP",
        // "Ocean Eyes" by Billie Eilish
        "7hDVYcQq6MxkdJGweuCtl9",
        // "Paper Thin" by Illenium
        "33LQdszht4rDfgmOSth8W0",
        // "Cold Water" by Major Lazer ft. Justin Bieber
        "7zsXy7vlHdItvUSH8EwQss"
    ],
    "hip-hop": [
        // "Lucid Dreams" by Juice WRLD
        "285pBltuF7vW8TeWk8hdRR",
        // "Sad!" by XXXTENTACION
        "3ee8Jmje8o58CHK66QrVC2",
        // "Love Yourz" by J. Cole
        "2e3Ea0o24lReQFR4FA7yXH",
        // "Mockingbird" by Eminem
        "561jH07mF1jHuk7KlaeF0s",
        // "I'll Be Missing You" by Diddy ft. Faith Evans & 112
        "3QHONiXGMGU3z68mQInncF",
        // "See You Again" by Wiz Khalifa ft. Charlie Puth
        "2JzZzZUQj3Qff7wapcbKjc",
        // "Stan" by Eminem ft. Dido
        "3UmaczJpikHgJFyBTAJVoz",
        // "Changes" by 2Pac
        "1ofhfV90EnYhEr7Un2fWiv",
        // "Suicidal" by YNW Melly
        "1iSqfoUFnQwV0QW1EfUit8",
        // "Street Lights" by Kanye West
        "6j8gTlbhj9KJSeypNcNAS9"
    ],
    "jazz": [
        // "Strange Fruit" by Billie Holiday
        "1CTex49P0iWwzUGsMNjgaV",
        // "Lush Life" by John Coltrane
        "0Srs2sPdZTfFvvfLP4DGa0",
        // "Round Midnight" by Thelonious Monk
        "1wl5b2lw3YagQtZiYZbQWP",
        // "My Funny Valentine" by Chet Baker
        "4l9hml2UCnxoNI3yCdL1BW",
        // "Goodbye Pork Pie Hat" by Charles Mingus
        "3PJMsxg6rz9FOo6xNiASXz",
        // "Solitude" by Duke Ellington
        "75SSwgtBqy5V0BaXDFKDrH",
        // "Mood Indigo" by Nina Simone
        "1BaAzMva4yf7cWeOGwp7H4",
        // "Don't Explain" by Billie Holiday
        "6GLMwwNDbiiBe4D9JcSOwP",
        // "In a Sentimental Mood" by John Coltrane & Duke Ellington
        "2hTVk5hOmvJJQUiTzi2I7m",
        // "Autumn Leaves" by Miles Davis
        "0OWqCRUi7l27d3rv1WDtCq"
    ],
    "pop": [],
    "r&b": [],
    "rock": []
]
