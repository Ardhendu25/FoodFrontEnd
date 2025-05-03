importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyDKaN2OjtHsjyscLgTXjpSN2oBQgdreE9k",
    appId: "1:866320770453:android:2f1262b7673c196a7ac29c",
    messagingSenderId: "866320770453",
    projectId: "flutter-food-delivery-ap-5903b",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
  
});
