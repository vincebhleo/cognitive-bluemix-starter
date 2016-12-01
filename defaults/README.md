## Cognitive Node-RED flow

A default Node-RED flow will be deployed integrating Watson IoT platform and Watson Conversation service for cognitive use cases to return weather and date/time informated based on the location detected from web browser or devices (Android & iOS).

This is based on different intents detected from Watson Conversation and routed different third party API (such as The Weather Service).

Node-RED flow editor can be accessed as below or on the Node-RED radio button on the default web app with the username **admin** and password **password**.

`https://<application_name_url>/red`

Please add Watson Conversation workspace ID after [training the service] [train_conversation], The Weather Service credential and The Watson Text-to-Speech credential (optional).

[train_conversation]: https://github.com/vincebhleo/cognitive-bluemix-starter/tree/master/training#training-the-conversation-workspace
