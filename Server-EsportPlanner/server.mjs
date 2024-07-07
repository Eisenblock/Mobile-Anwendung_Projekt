import express from 'express';
import fetch from 'node-fetch';
import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

const app = express();
const port = 3000;
let mongoServer;

// Middleware für JSON-Anfragen
app.use(express.json());

// Starten von mongodb-memory-server
async function startMongoMemoryServer() {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  await mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  console.log('Verbunden mit der eingebetteten Datenbank');
}

// Middleware zum Starten der MongoDB-Verbindung
startMongoMemoryServer().catch(err => {
  console.error('Fehler beim Starten der eingebetteten Datenbank:', err);
  process.exit(1); // Beende die Anwendung bei einem Fehler
});

// Schema und Modell wie zuvor definieren
const userSchema = new mongoose.Schema({
  name: String,
  selectedGames: [String],
  selectedLeagues_lol: [String],
  selectedLeagues_valo: [String],
  selectedTeams_lol: [String],
  selectedTeams_valo: [String],
  username: String,
  password: String
});
const User = mongoose.model('user', userSchema);


app.put('/user/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const { selectedGames , selectedLeagues_lol,selectedLeagues_valo,selectedTeams_lol,selectedTeams_valo} = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { selectedGames: selectedGames,selectedLeagues_lol: selectedLeagues_lol,selectedLeagues_valo: selectedLeagues_valo,selectedTeams_lol: selectedTeams_lol,selectedTeams_valo: selectedTeams_valo},
      { new: true }
    );
    console.log(user);

    if (!user) {
      return res.status(404).send('Benutzer nicht gefunden');
    }

    res.json(user);
  } catch (error) {
    res.status(500).send('Fehler beim Aktualisieren des Benutzers');
  }
});

app.post('/user', async (req, res) => {
  try {
    const { name, selectedGames, username, password } = req.body;
    const userData = { name, selectedGames, username, password };
    const user = new User(userData);
    await user.save();
    res.status(201).send('Benutzerdaten gespeichert');
  } catch (error) {
    console.error('Fehler beim Speichern der Benutzerdaten:', error);
    res.status(500).send('Interner Serverfehler');
  }
});



app.get('/user', async (req, res) => {
  try {
    // Alle Benutzer aus der Datenbank abrufen
    const users = await User.find();

    // Ergebnis als JSON zurücksenden
    const userArray = users.map(user => ({
      _id: user._id,
      name: user.name,
      selectedGames: user.selectedGames,
      selectedLeagues: user.selectedLeagues,
      username: user.username,
      password: user.password,
      // Weitere Felder nach Bedarf hinzufügen
    }));
    console.log(users);

    res.json({ users: userArray });
  } catch (error) {
    console.error('Fehler beim Abrufen der Benutzerdaten:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

app.get('/user/:_id/upcoming-matches', async (req, res) => {
  try {
    const userId = req.params._id;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).send('Benutzer nicht gefunden');
    }

    // Spiele, die der Benutzer ausgewählt hat
    const selectedGames = user.selectedGames;
    const selectedLeagues = user.selectedLeagues;
    const selectedLeagues_lol = user.selectedLeagues_lol;
    const selectedLeagues_valo = user.selectedLeagues_valo;
    const selectedTeams_lol = user.selectedTeams_lol;
    const selectedTeams_valo = user.selectedTeams_valo;
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';

    const combinedData = {};

    for (const game of selectedGames) {
      let apiUrl;
      if (game === 'lol') {
          apiUrl = 'https://api.pandascore.co/lol/matches/upcoming';
      } else if (game === 'valorant') {
          apiUrl = 'https://api.pandascore.co/valorant/matches/upcoming';
      } else if (game === 'csgo') {
        apiUrl = 'https://api.pandascore.co/csgo/matches/upcoming';
      } 
      // Senden einer GET-Anfrage an die Pandascore-API für jedes Spiel
      const response = await fetch(`${apiUrl}?token=${apiKey}`);
      const data = await response.json();
      
      // Extrahiere nur die gewünschten Informationen aus den abgerufenen Daten
      var filteredData = data.map(match => ({
        name: match.name,
        opponents: match.opponents,  
        begin_at: match.begin_at,
        league: match.league.name,
        leagueurl: match.league.image_url,
        serie: match.serie.name,
        videogame: match.videogame.name,
        // Füge weitere Felder hinzu, die du senden möchtest
      }));

      // Filtern der Daten nach den ausgewählten Ligen
    /*
      if(game == 'lol'&& selectedLeagues_lol.length > 0){
    
        filteredData = filteredData.filter(match => selectedLeagues_lol.includes(match.league));
        console.log(filteredData);
      }else{
        console.log("Keine Liga ausgewählt");
        console.log(filteredData);
      }
      
      if(game == 'valorant'&& selectedLeagues_valo.length > 0){
        filteredData = filteredData.filter(match => selectedLeagues_valo.includes(match.league));
        console.log(filteredData);
      }else{
        console.log("Keine Liga ausgewählt");
        console.log(filteredData);
      }


      // Filtern der Daten nach den ausgewählten Teams

      if(game == 'lol'&& selectedTeams_lol.length > 1){
        const lolfilteredData = filteredData.filter(match => match.opponents[0].opponent.name == selectedTeams_lol || match.opponents[1].opponent.name == selectedTeams_lol);
        console.log(lolfilteredData);
      }else{
        console.log("Kein Team ausgewählt");
        
      }

      if(game == 'valorant'&& selectedTeams_valo.length > 0){
        filteredData = filteredData.filter(match => match.opponents[0].opponent.name == selectedTeams_valo || match.opponents[1].opponent.name == selectedTeams_valo);
      }else{
        console.log("Kein Team ausgewählt");
      }*/

      

     
        combinedData[game] = filteredData;
     

    }

  //  console.log(combinedData);
    // Senden der kombinierten und gefilterten Daten als JSON an das Frontend
    res.json(combinedData);
  } catch (error) {
    console.error('Fehler beim Abrufen der bevorstehenden Spiele:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

app.get('/allGames/leagues', async (req, res) => {
  try {
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
    const apiUrlLOL = 'https://api.pandascore.co/lol/leagues';
    const apiUrlVALO = 'https://api.pandascore.co/valorant/leagues';

    // Parallele Ausführung der beiden API-Anfragen
    const [responseLOL, responseVALO] = await Promise.all([
      fetch(`${apiUrlLOL}?token=${apiKey}`),
      fetch(`${apiUrlVALO}?token=${apiKey}`)
    ]);

    // Überprüfung der Antworten
    if (!responseLOL.ok || !responseVALO.ok) {
      throw new Error('Error fetching data');
    }

    // Extrahieren der Daten aus den Antworten
    const dataLOL = await responseLOL.json();
    const dataVALO = await responseVALO.json();

    // Filtern und Mappen der Daten für League of Legends
    const filteredDataLOL = dataLOL.map(league => ({
        name: league.name,
        season: league.series[0].season 
      }));

    // Filtern und Mappen der Daten für Valorant
    const filteredDataVALO = dataVALO
      .filter(league => league.series[0].season !== null)
      .map(league => ({
        name: league.name
      }));

    // Kombinieren der Daten
    const combinedData = {
      lolLeagues: filteredDataLOL,
      valorantLeagues: filteredDataVALO
    };

    // Senden der kombinierten Daten als JSON-Antwort
    res.status(200).json(combinedData);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/allGames/teams', async (req, res) => {
  try {
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
    const apiUrlLOL = 'https://api.pandascore.co/lol/teams';
    const apiUrlVALO = 'https://api.pandascore.co/valorant/teams';

    // Parallele Ausführung der beiden API-Anfragen
    const [responseLOL, responseVALO] = await Promise.all([
      fetch(`${apiUrlLOL}?token=${apiKey}`),
      fetch(`${apiUrlVALO}?token=${apiKey}`)
    ]);

    // Überprüfung der Antworten
    if (!responseLOL.ok || !responseVALO.ok) {
      throw new Error('Error fetching data');
    }

    // Extrahieren der Daten aus den Antworten
    const dataLOL = await responseLOL.json();
    const dataVALO = await responseVALO.json();

    // Filtern und Mappen der Daten für League of Legends
    const filteredDataLOL = dataLOL.map(team => ({
        videogame: "lol",
        name: team.name,
        players : team.players,
      }));

    // Filtern und Mappen der Daten für Valorant
    const filteredDataVALO = dataVALO.map(team => ({
        videogame: "valorant",
        name: team.name,
        players : team.players,
      }));

    // Kombinieren der Daten
    const combinedData = {
      lolTeams: filteredDataLOL,
      valorantTeams: filteredDataVALO
    };

    // Senden der kombinierten Daten als JSON-Antwort
    res.status(200).json(combinedData);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/lol/teams', async (req, res) => {

  const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
  const apiUrl = 'https://api.pandascore.co/lol/teams';
  const response = await fetch(`${apiUrl}?token=${apiKey}`);
  const data = await response.json();

  const filteredData = data // Filtern der Ligen, bei denen season nicht null ist
    .map(team => ({
      name: team.name,
      players : team.players,
    }));



  res.json({teams : filteredData});
});

app.get('/teams', async (req, res) => {
  const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
  const apiUrl = 'https://api.pandascore.co/matches/past';
  const response = await fetch(`${apiUrl}?token=${apiKey}`);
  const data = await response.json();

  const filteredData = data // Filtern der Ligen, bei denen season nicht null ist
    .map(match => ({
      team: match.opponents[0].opponent.name,
      team2: match.opponents[1].opponent.name,
    }));

    res.json({teams : filteredData});
});

app.get('/past-matches', async (req, res) => {
  try {
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
    const games = ['lol', 'valorant']; // Liste aller Spiele, die abgerufen werden sollen

    const combinedData = {};

    for (const game of games) {
      let apiUrl;
      if (game === 'lol') {
          apiUrl = 'https://api.pandascore.co/lol/matches/past';
      } else if (game === 'valorant') {
          apiUrl = 'https://api.pandascore.co/valorant/matches/past';
      } 
      // Senden einer GET-Anfrage an die Pandascore-API für jedes Spiel
      const response = await fetch(`${apiUrl}?token=${apiKey}`);
      const data = await response.json();
      
      // Extrahiere nur die gewünschten Informationen aus den abgerufenen Daten
      const filteredData = data.map(match => ({
        videogame: game,
        name: match.name,
        opponents: match.opponents,  
        begin_at: match.begin_at,
        league: match.league.name,
        leagueurl: match.league.image_url,
        serie: match.serie.name,
        results: match.results,
        // Füge weitere Felder hinzu, die du senden möchtest
      }));
      

      // Speichern der gefilterten Daten für jedes Spiel separat
      combinedData[game] = filteredData;
    }

    console.log(combinedData);
    // Senden der kombinierten und gefilterten Daten als JSON an das Frontend
    res.json(combinedData);
  } catch (error) {
    console.error('Fehler beim Abrufen der bevorstehenden Spiele:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

// Starten des Servers
app.listen(port, () => {
  console.log(`Server läuft auf http://localhost:${port}`);
});
