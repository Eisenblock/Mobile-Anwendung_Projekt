import express from 'express';
import fetch from 'node-fetch';

const app = express();
const port = 3000;

// Middleware für JSON-Anfragen
app.use(express.json());

app.get('/upcoming-matches', async (req, res) => {
  try {
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';
    const games = ['lol', 'valorant']; // Liste aller Spiele, die abgerufen werden sollen

    const combinedData = {};

    for (const game of games) {
      let apiUrl;
      if (game === 'lol') {
          apiUrl = 'https://api.pandascore.co/lol/matches/upcoming';
      } else if (game === 'valorant') {
          apiUrl = 'https://api.pandascore.co/valorant/matches/upcoming';
      } 
      // Senden einer GET-Anfrage an die Pandascore-API für jedes Spiel
      const response = await fetch(`${apiUrl}?token=${apiKey}`);
      const data = await response.json();
      
      // Extrahiere nur die gewünschten Informationen aus den abgerufenen Daten
      const filteredData = data.map(match => ({
        name: match.name,
        opponents: match.opponents,  
        begin_at: match.begin_at,
        league: match.league.name,
        leagueurl: match.league.image_url,
        serie: match.serie.name,
        Game_name: match.videogame.name,
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
        name: match.name,
        opponents: match.opponents,  
        begin_at: match.begin_at,
        league: match.league.name,
        leagueurl: match.league.image_url,
        serie: match.serie.name,
        name: match.videogame.name,
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
