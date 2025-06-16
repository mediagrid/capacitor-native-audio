export const handler = async event => {
    const metadata = [
        {
            album_title: 'Abbey Road',
            artist_name: 'The Beatles',
            song_title: 'Here Comes the Sun',
            artwork_source: 'https://placehold.co/1200.jpg?text=Here+Comes+the+Sun',
        },
        {
            album_title: 'Back in Black',
            artist_name: 'AC/DC',
            song_title: 'Back in Black',
            artwork_source: 'https://placehold.co/1200.jpg?text=Back+in+Black',
        },
        {
            album_title: 'Bad Romance',
            artist_name: 'Lady Gaga',
            song_title: 'Bad Romance',
            artwork_source: 'https://placehold.co/1200.jpg?text=Bad+Romance',
        },
        {
            album_title: 'Blonde',
            artist_name: 'Frank Ocean',
            song_title: 'Good Guy',
            artwork_source: 'https://placehold.co/1200.jpg?text=Good+Guy',
        },
        {
            album_title: 'Born to Run',
            artist_name: 'Bruce Springsteen',
            song_title: 'Born to Run',
            artwork_source: 'https://placehold.co/1200.jpg?text=Born+to+Run',
        },
        {
            album_title: 'Fearless',
            artist_name: 'Taylor Swift',
            song_title: 'Teardrops on My Guitar',
            artwork_source: 'https://placehold.co/1200.jpg?text=Teardrops+on+My+Guitar',
        },
        {
            album_title: 'good kid, m.A.A.d city',
            artist_name: 'Kendrick Lamar',
            song_title: "Bitch Don't Kill My Vibe",
            artwork_source: "https://placehold.co/1200.jpg?text=Bitch+Don't+Kill+My+Vibe",
        },
        {
            album_title: 'In the Court of the Crimson King',
            artist_name: 'King Crimson',
            song_title: '21st Century Schizoid Man',
            artwork_source: 'https://placehold.co/1200.jpg?text=21st+Century+Schizoid+Man',
        },
        {
            album_title: 'London Calling',
            artist_name: 'The Clash',
            song_title: 'London Calling',
            artwork_source: 'https://placehold.co/1200.jpg?text=London+Calling',
        },
        {
            album_title: 'Meddle',
            artist_name: 'Pink Floyd',
            song_title: 'One of These Days',
            artwork_source: 'https://placehold.co/1200.jpg?text=One+of+These+Days',
        },
        {
            album_title: 'Nevermind',
            artist_name: 'Nirvana',
            song_title: 'Smells Like Teen Spirit',
            artwork_source: 'https://placehold.co/1200.jpg?text=Smells+Like+Teen+Spirit',
        },
        {
            album_title: 'Pet Sounds',
            artist_name: 'The Beach Boys',
            song_title: "Wouldn't It Be Nice",
            artwork_source: "https://placehold.co/1200.jpg?text=Wouldn't+It+Be+Nice",
        },
        {
            album_title: 'Purple Rain',
            artist_name: 'Prince',
            song_title: 'Purple Rain',
            artwork_source: 'https://placehold.co/1200.jpg?text=Purple+Rain',
        },
        {
            album_title: 'Rumours',
            artist_name: 'Fleetwood Mac',
            song_title: 'Dreams',
            artwork_source: 'https://placehold.co/1200.jpg?text=Dreams',
        },
        {
            album_title: "Sgt. Pepper's Lonely Hearts Club Band",
            artist_name: 'The Beatles',
            song_title: 'A Day in the Life',
            artwork_source: 'https://placehold.co/1200.jpg?text=A+Day+in+the+Life',
        },
        {
            album_title: 'Songs in the Key of Life',
            artist_name: 'Stevie Wonder',
            song_title: 'Living for the City',
            artwork_source: 'https://placehold.co/1200.jpg?text=Living+for+the+City',
        },
        {
            album_title: 'Super freak',
            artist_name: 'Rick Astley',
            song_title: 'Never Gonna Give You Up',
            artwork_source: 'https://placehold.co/1200.jpg?text=Never+Gonna+Give+You+Up',
        },
        {
            album_title: 'The Blueprint',
            artist_name: 'Jay-Z',
            song_title: '99 Problems',
            artwork_source: 'https://placehold.co/1200.jpg?text=99+Problems',
        },
        {
            album_title: 'The Dark Side of the Moon',
            artist_name: 'Pink Floyd',
            song_title: 'Money',
            artwork_source: 'https://placehold.co/1200.jpg?text=Money',
        },
        {
            album_title: 'The Day Is Gone',
            artist_name: 'Miles Davis',
            song_title: 'All Blues',
            artwork_source: 'https://placehold.co/1200.jpg?text=All+Blues',
        },
        {
            album_title: 'The Joshua Tree',
            artist_name: 'U2',
            song_title: 'Where the Streets Have No Name',
            artwork_source: 'https://placehold.co/1200.jpg?text=Where+the+Streets+Have+No+Name',
        },
        {
            album_title: 'The Miseducation of Lauryn Hill',
            artist_name: 'Lauryn Hill',
            song_title: 'Everything Is Everything',
            artwork_source: 'https://placehold.co/1200.jpg?text=Everything+Is+Everything',
        },
        {
            album_title: 'The Sound of Silence',
            artist_name: 'Simon & Garfunkel',
            song_title: 'The Sound of Silence',
            artwork_source: 'https://placehold.co/1200.jpg?text=The+Sound+of+Silence',
        },
        {
            album_title: 'The Velvet Underground & Nico',
            artist_name: 'The Velvet Underground',
            song_title: 'Pale Blue Eyes',
            artwork_source: 'https://placehold.co/1200.jpg?text=Pale+Blue+Eyes',
        },
        {
            album_title: 'The Wall',
            artist_name: 'Pink Floyd',
            song_title: 'Another Brick in the Wall',
            artwork_source: 'https://placehold.co/1200.jpg?text=Another+Brick+in+the+Wall',
        },
        {
            album_title: 'Thriller',
            artist_name: 'Michael Jackson',
            song_title: 'Thriller',
            artwork_source: 'https://placehold.co/1200.jpg?text=Thriller',
        },
    ];

    const otherData = {
        other_data_number: Math.floor(Math.random() * 1000000),
        other_data_text: crypto.randomUUID(),
    };

    let body = metadata[Math.floor(Math.random() * metadata.length)];

    if (event.queryStringParameters?.includeOtherData === '1') {
        body = { ...body, ...otherData };
    }

    const response = {
        statusCode: 200,
        body: body,
    };

    return response;
};
