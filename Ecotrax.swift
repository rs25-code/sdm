//
// Ecotrax.swift
//
// This file was automatically generated and should not be edited.
//
import CoreML
/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *)
class EcotraxInput : MLFeatureProvider {
    /// Species as string value
    var Species: String
    /// Latitude as double value
    var Latitude: Double
    /// Longitude as double value
    var Longitude: Double
    /// Temperature_C as double value
    var Temperature_C: Double
    /// Precipitation_mm as double value
    var Precipitation_mm: Double
    /// NDVI as double value
    var NDVI: Double
    /// Fire_Occurred as string value
    var Fire_Occurred: String
    /// Fire_Size_km2 as double value
    var Fire_Size_km2: Double
    var featureNames: Set<String> { ["Species", "Latitude", "Longitude", "Temperature_C", "Precipitation_mm", "NDVI", "Fire_Occurred", "Fire_Size_km2"] }
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "Species" {
            return MLFeatureValue(string: Species)
        }
        if featureName == "Latitude" {
            return MLFeatureValue(double: Latitude)
        }
        if featureName == "Longitude" {
            return MLFeatureValue(double: Longitude)
        }
        if featureName == "Temperature_C" {
            return MLFeatureValue(double: Temperature_C)
        }
        if featureName == "Precipitation_mm" {
            return MLFeatureValue(double: Precipitation_mm)
        }
        if featureName == "NDVI" {
            return MLFeatureValue(double: NDVI)
        }
        if featureName == "Fire_Occurred" {
            return MLFeatureValue(string: Fire_Occurred)
        }
        if featureName == "Fire_Size_km2" {
            return MLFeatureValue(double: Fire_Size_km2)
        }
        return nil
    }
    init(Species: String, Latitude: Double, Longitude: Double, Temperature_C: Double, Precipitation_mm: Double, NDVI: Double, Fire_Occurred: String, Fire_Size_km2: Double) {
        self.Species = Species
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Temperature_C = Temperature_C
        self.Precipitation_mm = Precipitation_mm
        self.NDVI = NDVI
        self.Fire_Occurred = Fire_Occurred
        self.Fire_Size_km2 = Fire_Size_km2
    }
}
/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *)
class EcotraxOutput : MLFeatureProvider {
    /// Source provided by CoreML
    private let provider : MLFeatureProvider
    /// Count as double value
    var Count: Double {
        provider.featureValue(for: "Count")!.doubleValue
    }
    var featureNames: Set<String> {
        provider.featureNames
    }
    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }
    init(Count: Double) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["Count" : MLFeatureValue(double: Count)])
    }
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}
/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, visionOS 1.0, *)
class Ecotrax {
    let model: MLModel
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "Ecotrax", withExtension:"mlmodelc")!
    }
    /**
        Construct Ecotrax instance with an existing MLModel object.
        Usually the application does not use this initializer unless it makes a subclass of Ecotrax.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `Ecotrax.urlOfModelInThisBundle` to create a MLModel object to pass-in.
        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }
    /**
        Construct Ecotrax instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    /**
        Construct a model with configuration
        - parameters:
           - configuration: the desired model configuration
        - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, visionOS 1.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    /**
        Construct Ecotrax instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model
        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }
    /**
        Construct a model with URL of the .mlmodelc directory and configuration
        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration
        - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, visionOS 1.0, *)
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }
    /**
        Construct Ecotrax instance asynchronously with optional configuration.
        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Ecotrax, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }
    /**
        Construct Ecotrax instance asynchronously with optional configuration.
        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Ecotrax {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }
    /**
        Construct Ecotrax instance asynchronously with URL of the .mlmodelc directory with optional configuration.
        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Ecotrax, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(Ecotrax(model: model)))
            }
        }
    }
    /**
        Construct Ecotrax instance asynchronously with URL of the .mlmodelc directory with optional configuration.
        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Ecotrax {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return Ecotrax(model: model)
    }
    /**
        Make a prediction using the structured interface
        It uses the default function if the model has multiple functions.
        - parameters:
           - input: the input to the prediction as EcotraxInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as EcotraxOutput
    */
    func prediction(input: EcotraxInput) throws -> EcotraxOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }
    /**
        Make a prediction using the structured interface
        It uses the default function if the model has multiple functions.
        - parameters:
           - input: the input to the prediction as EcotraxInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as EcotraxOutput
    */
    func prediction(input: EcotraxInput, options: MLPredictionOptions) throws -> EcotraxOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return EcotraxOutput(features: outFeatures)
    }
    /**
        Make an asynchronous prediction using the structured interface
        It uses the default function if the model has multiple functions.
        - parameters:
           - input: the input to the prediction as EcotraxInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as EcotraxOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: EcotraxInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> EcotraxOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return EcotraxOutput(features: outFeatures)
    }
    /**
        Make a prediction using the convenience interface
        It uses the default function if the model has multiple functions.
        - parameters:
            - Species: string value
            - Latitude: double value
            - Longitude: double value
            - Temperature_C: double value
            - Precipitation_mm: double value
            - NDVI: double value
            - Fire_Occurred: string value
            - Fire_Size_km2: double value
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as EcotraxOutput
    */
    func prediction(Species: String, Latitude: Double, Longitude: Double, Temperature_C: Double, Precipitation_mm: Double, NDVI: Double, Fire_Occurred: String, Fire_Size_km2: Double) throws -> EcotraxOutput {
        let input_ = EcotraxInput(Species: Species, Latitude: Latitude, Longitude: Longitude, Temperature_C: Temperature_C, Precipitation_mm: Precipitation_mm, NDVI: NDVI, Fire_Occurred: Fire_Occurred, Fire_Size_km2: Fire_Size_km2)
        return try prediction(input: input_)
    }
    /**
        Make a batch prediction using the structured interface
        It uses the default function if the model has multiple functions.
        - parameters:
           - inputs: the inputs to the prediction as [EcotraxInput]
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [EcotraxOutput]
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, visionOS 1.0, *)
    func predictions(inputs: [EcotraxInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [EcotraxOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [EcotraxOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  EcotraxOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}

