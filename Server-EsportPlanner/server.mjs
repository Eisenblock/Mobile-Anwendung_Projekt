import express from 'express';
import fetch from 'node-fetch';

const app = express();
const port = 3000;

// Middleware für JSON-Anfragen
app.use(express.json());

// Route für GET-Anfrage
app.get('/upcoming-matches-lol', async (req, res) => {
  try {
    // API-Endpoint für bevorstehende Spiele
    const apiUrl = 'https://api.pandascore.co/lol/matches/upcoming';
    // Fügen Sie Ihren Pandascore API-Token hier ein
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';

    // Senden einer GET-Anfrage an die Pandascore-API
    const response = await fetch(`${apiUrl}?token=${apiKey}`);
    const data = await response.json();
    console.log('Bevorstehende Spiele:', data);

    // Senden der erhaltenen Daten als JSON an das Frontend
    res.json(data);
  } catch (error) {
    console.error('Fehler beim Abrufen der bevorstehenden Spiele:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

app.get('/upcoming-matches-valorant', async (req, res) => {
  try {
    // API-Endpoint für bevorstehende Spiele
    const apiUrl = 'https://api.pandascore.co/valorant/matches/upcoming';
    // Fügen Sie Ihren Pandascore API-Token hier ein
    const apiKey = 'UTMd3q96vtvq4-izN1bAeHbo5c9xoA8vGzaztOUk3obRJi3WVfM';

    // Senden einer GET-Anfrage an die Pandascore-API
    const response = await fetch(`${apiUrl}?token=${apiKey}`);
    const data = await response.json();
    console.log('Bevorstehende Spiele:', data);

    // Senden der erhaltenen Daten als JSON an das Frontend
    res.json(data);
  } catch (error) {
    console.error('Fehler beim Abrufen der bevorstehenden Spiele:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

// Starten des Servers
app.listen(port, () => {
  console.log(`Server läuft auf http://localhost:${port}`);
});
