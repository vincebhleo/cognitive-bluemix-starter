Cognitive Watson Bluemix Starter Application
======================================

### Cognitive Watson in Bluemix

This repository is an example Natural Language Interface for Things application that includes a Node.js and/or Node-RED backend services connected to various client (Android, iOS and Raspberry Pi).

This starter application includes the following Watson and Internet of Things services integrated:

- Cloudant NoSQL DB
A fully managed data layer designed for modern web and mobile applications that leverages a flexible JSON schema.

- Conversation
Adds a natural language interface to your application to automate interactions with your end users.

- Speech to Text
Low-latency, streaming transcription.

- Text to Speech
Synthesizes natural-sounding speech from text.

- Internet of Things Platform
The service lets your apps communicate with and consume data collected by your connected devices, sensors, and gateways.

This can be deployed into Bluemix with only a couple clicks. Try it out for yourself right now by clicking:

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/vincebhleo/cognitive-bluemix-starter.git)

### How does this work?

When you click the button, you will be taken to Bluemix. The name of the application will be pre-filled however you type your own name for your application, select the server and development space. Click the DEPLOY button and the application will be deployed with all examples included.

It will automatically create an instance of the defined services above, named as cognitive-<Service Name> and binded to your app. If you deploy multiple instances this repository, they will share the one instance of the services.
