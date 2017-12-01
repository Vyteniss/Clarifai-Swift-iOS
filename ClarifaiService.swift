//
//  ClarifaiService.swift
//
//  Created by Vytenis Sabelka on 26/10/2017.
//

import UIKit
import Alamofire

class ClarifaiService {

    var apiKey: String
    var modelId: String
    
    struct Config {
        static let BaseURL: String = "https://api.clarifai.com/v2"
    }
    
    init(apiKey: String, modelId: String) {
        self.apiKey = apiKey
        self.modelId = modelId
    }
    
    func predictFromUrl(imageSrc: String, completion: @escaping (Response) -> ()) {
        performPrediction(imageSrc: imageSrc, inBytes: false, completion: completion)
    }
    
    func predictFromBytes(imageSrc: String, completion: @escaping (Response) -> ()) {
        performPrediction(imageSrc: imageSrc, inBytes: true, completion: completion)
    }
    
    private func performPrediction(imageSrc: String, inBytes: Bool, completion: @escaping (Response) -> ()) {
        Alamofire.request(
        getQueryUrl(),
        method: .post,
        parameters: constructPostBody(imageSrc: imageSrc, inBytes: inBytes),
        encoding: JSONEncoding.default,
        headers: constructHttpHeaders())
        .responseJSON {
            response in
            switch response.result {
                case .success(let value):
                    let jsonResponse = JSON(value)
                    let responseModel = Response(data: jsonResponse)
                    completion(responseModel)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // Aux methods
    private func getQueryUrl() -> String {
        return Config.BaseURL + "/models/" + modelId + "/outputs"
    }
    
    private func constructPostBody(imageSrc: String, inBytes: Bool) -> Parameters {
        let type = inBytes ? "base64" : "url"
        return [
            "inputs" : [[
                "data": [
                    "image": [
                        type : imageSrc
                    ]
                ]
            ]]
        ]
    }
    
    private func constructHttpHeaders() -> HTTPHeaders {
        return [
            "Authorization": "Key " + self.apiKey,
            "Accept": "application/json"
        ]
    }
    
    //JSON classes
    class Response {
        var status: Status
        var outputs: [Output]
        
        init(data: JSON) {
            var outputs = [Output]()
            
            for outputJson in data["outputs"] {
                outputs.append(Output(jsonData: outputJson.1))
            }

            self.status = Status(data: data["status"])
            self.outputs = outputs
        }
    }
    
    class Status {
        var code: Double
        var description: String
        
        init(code: Double, description: String) {
            self.code = code
            self.description = description
        }
        
        init(data: JSON) {
            self.code = data["code"].doubleValue
            self.description = data["description"].stringValue
        }
    }
    
    class Model {
        var name: String
        var id: String
        var createdAt: String
        var appId: String
        var outputInfo: OutputInfo
        var modelVersion: ModelVersion
        
        init(name: String, id: String, createdAt: String, appId: String, outputInfo: OutputInfo, modelVersion: ModelVersion) {
            self.name = name
            self.id = id
            self.createdAt = createdAt
            self.appId = appId
            self.outputInfo = outputInfo
            self.modelVersion = modelVersion
        }
        
        init(jsonData: JSON) {
            self.name = jsonData["name"].stringValue
            self.id = jsonData["id"].stringValue
            self.createdAt = jsonData["created_at"].stringValue
            self.appId = jsonData["app_id"].stringValue
            self.outputInfo = OutputInfo(jsonData: jsonData["output_info"])
            self.modelVersion = ModelVersion(jsonData: jsonData["model_version"])
        }
        
        class OutputInfo {
            var message: String
            var type: String
            
            init(message: String, type: String) {
                self.message = message
                self.type = type
            }
            
            init(jsonData: JSON) {
                self.message = jsonData["message"].stringValue
                self.type = jsonData["type"].stringValue
            }
        }
        
        class ModelVersion {
            var id: String
            var createdAt: String
            var status: Status
            
            init(id: String, createdAt: String, status: Status) {
                self.id = id
                self.createdAt = createdAt
                self.status = status
            }
            
            init(jsonData: JSON) {
                self.id = jsonData["id"].stringValue
                self.createdAt = jsonData["created_at"].stringValue
                self.status = Status(data: jsonData["status"])
            }
        }
    }
    
    class Data {
        var concepts: [Concept]
        
        init(concepts: [Concept]) {
            self.concepts = concepts
        }
        
        init(jsonData: JSON) {
            var concepts = [Concept]()
            for conceptJson in jsonData["concepts"] {
                concepts.append(Concept(jsonData: conceptJson.1))
            }
            self.concepts = concepts
        }
        
        class Concept {
            var id: String
            var name: String
            var appId: String
            var value: Double
            
            init(id: String, name: String, appId: String, value: Double) {
                self.id = id
                self.name = name
                self.appId = appId
                self.value = value
            }
            
            init(jsonData: JSON) {
                self.id = jsonData["id"].stringValue
                self.name = jsonData["name"].stringValue
                self.appId = jsonData["appId"].stringValue
                self.value = jsonData["value"].doubleValue
            }
        }
    }
    
    class Output {
        var id: String
        var status: Status
        var createdAt: String
        var model: Model
        //var input: Input INPUT OMMITED FOR NOW
        var data: Data
        
        init(id: String, status: Status, createdAt: String, model: Model, data: Data) {
            self.id = id
            self.status = status
            self.createdAt = createdAt
            self.model = model
            self.data = data
        }
        
        init(jsonData: JSON) {
            self.id = jsonData["id"].stringValue
            self.status = Status(data: jsonData["status"])
            self.createdAt = jsonData["created_at"].stringValue
            self.model = Model(jsonData: jsonData["model"])
            self.data = Data(jsonData: jsonData["data"])
        }
    }
}

