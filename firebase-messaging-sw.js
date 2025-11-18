/*if ('serviceWorker' in navigator) {
navigator.serviceWorker.register('../firebase-messaging-sw.js')
.then(function(registration) {
console.log('Registration successful, scope is:', registration.scope);
}).catch(function(err) {
console.log('Service worker registration failed, error:', err);
});
}
*/
// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyDx0Mwt6TgnF4s3f-JIjZJ08nLNKqs37mw',
  appId: '1:945547363766:web:2b677a52f1a3a8d26aed17',
  messagingSenderId: '945547363766',
  projectId: 'trabalho-final-cee76',
  authDomain: 'trabalho-final-cee76.firebaseapp.com',
  storageBucket: 'trabalho-final-cee76.firebasestorage.app',
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});