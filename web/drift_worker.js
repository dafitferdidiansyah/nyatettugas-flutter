// web/drift_worker.js
// Script ini menghubungkan Drift dengan engine SQLite WASM
importScripts('sqlite3.js');

onconnect = (event) => {
  const port = event.ports[0];
  port.onmessage = (message) => {
    // Pesan dari Drift akan diproses di sini
    console.log('Worker received:', message.data);
  };
};