# Clarifai-Swift-iOS
Lightweight Clarifai (clarifai.com) client library written in pure Swift

Heavily based on the work of [jodyheavener](https://github.com/jodyheavener/Clarifai-iOS)

Adopted to work with Clarifai API V2 and Swift 4. NOTE both Alamofire and SwiftyJSON are required for this service to work correctly so make sure you have them.

Currently supports only image prediction endpoints by either image URL or by sumbiting base64 encoded image in bytes.

How To Use:
* Drag ClarifaiService.swift to your project
* Find the required clarifai [model](https://www.clarifai.com/models)
* Construct service by providing your API key and modelID
* Issue requests by calling predictFromUrl or predictFromBytes methods on the service class. You need to provide image source and callback methods to both of them
* Calbacks are passed with response object. (Structure)[https://www.clarifai.com/developer/guide/predictions#predictions]
