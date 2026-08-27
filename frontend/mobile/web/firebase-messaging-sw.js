importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);

importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyDUJzOWDQ6hA4CxYrEww3PKDVuZUtniXOo',
  authDomain: 'farmpilot-646c1.firebaseapp.com',
  projectId: 'farmpilot-646c1',
  storageBucket: 'farmpilot-646c1.firebasestorage.app',
  messagingSenderId: '103301243361',
  appId: '1:103301243361:web:7b987cb1240b2c3429f2a0',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    'FarmPilot background message received:',
    payload,
  );
});