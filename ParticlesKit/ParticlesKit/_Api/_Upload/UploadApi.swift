//
//  UploadApi.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/13/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc open class UploadApi: HttpApi {
    private var session: URLSession?
    private var task: URLSessionUploadTask? {
        didSet {
            if task !== oldValue {
                task?.resume()
            }
        }
    }

    private var file: String? {
        didSet {
            uploadFile = multipart(file: file)
        }
    }

    private var responseData: [String: Data] = [:]
    private var completion: ApiCompletionHandler?
    private var progress: ApiProgressHandler?

    open var imageTag: String = "input_image"

    private var uploadFile: String? {
        didSet {
            if uploadFile != oldValue {
                if let oldValue = oldValue {
                    File.delete(oldValue)
                }
            }
        }
    }

    deinit {
        file = nil
    }

    open func upload(path: String, identifier: String, params: [String: Any]?, body: [String: Any]?, file: String?, completion: @escaping ApiCompletionHandler, progress: ApiProgressHandler?) {
        let className = String(describing: type(of: self))
        if let server = server {
//            let config = URLSessionConfiguration.background(withIdentifier: identifier)
            let config = URLSessionConfiguration.default
            session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

            let pathAndParams = url(server: server, path: path, params: params)
            self.file = file
            if let uploadFile = uploadFile, let url = url(path: pathAndParams.urlPath, params: pathAndParams.paramStrings) {
                request(url: url, body: body) { [weak self] request in
                    if let self = self {
                        if let request = request {
                            let fileUrl = URL(fileURLWithPath: uploadFile)
                            self.completion = completion
                            self.progress = progress
                            self.task = self.session?.uploadTask(with: request, fromFile: fileUrl)
                        } else {
                            let error = NSError(domain: "\(className).request", code: 0, userInfo: nil)
                            ErrorLogging.shared?.log(error)
                            completion(nil, error)
                        }
                    }
                }
            } else {
                let error = NSError(domain: "\(className).file", code: 0, userInfo: nil)
                ErrorLogging.shared?.log(error)
                completion(nil, error)
            }
        } else {
            let error = NSError(domain: "\(className).server", code: 0, userInfo: nil)
            ErrorLogging.shared?.log(error)
            completion(nil, error)
        }
    }

    public func request(url: URL, body: Any?, completion: @escaping (_ request: URLRequest?) -> Void) {
        var fileData = Data()
        let boundary = UUID().uuidString
        if let file = file, let uploadFile = uploadFile, let separator = "\r\n--\(boundary)\r\n".data(using: .utf8), let eof = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
            let fileUrl = URL(fileURLWithPath: file)
            if let data = try? Data(contentsOf: fileUrl) {
                if let body = body as? [String: Any] {
                    for (key, value) in body {
                        if let keyText = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8), let valueText = "\(value)".data(using: .utf8) {
                            fileData.append(separator)
                            fileData.append(keyText)
                            fileData.append(valueText)
                        }
                    }
                }
                fileData.append(separator)
                fileData.append("Content-Disposition: form-data; name=\"\(imageTag)\"; filename=\"\(file.lastPathComponent)\"\r\n".data(using: .utf8)!)
                if let contentType = "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8) {
                    fileData.append(contentType)
                }
                fileData.append(data)
                fileData.append(eof)

                try? fileData.write(to: URL(fileURLWithPath: uploadFile))

                let verb: HttpVerb = .post
                var request: URLRequest = URLRequest(url: url)
                request.httpMethod = verb.rawValue
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                inject(request: request, verb: verb, index: 0) { /* [weak self] */ request in
                    var request = request
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    completion(request)
                }
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }

    private func multipart(file: String?) -> String? {
        if let file = file, let tempFolder = Directory.documentFolder("temp") {
            let fileName = file.lastPathComponent
            _ = Directory.ensure(tempFolder)
            return tempFolder.stringByAppendingPathComponent(path: fileName)
        }
        return nil
    }
}

extension UploadApi: URLSessionDelegate {
}

extension UploadApi: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        var persist = responseData["\(dataTask.taskIdentifier)"] ?? Data()
        persist.append(data)
        responseData["\(dataTask.taskIdentifier)"] = persist
    }
}

extension UploadApi: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        task.cancel()
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                self.task = nil
                let className = String(describing: type(of: self))
                let error = NSError(domain: "\(className).connection", code: 0, userInfo: nil)
                self.completion?(nil, error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            ErrorLogging.shared?.log(error)
            if let self = self, let response = task.response {
                self.file = nil
                self.status = nil

                let raw = self.responseData["\(task.taskIdentifier)"]
                let data = (raw != nil) ? try? JSONSerialization.jsonObject(with: raw!, options: []) : nil
                if let responseInjections = self.responseInjections {
                    for responseInjection in responseInjections {
                        responseInjection.inject(response: response, data: data, verb: .post)
                    }
                }
                if let data = data as? [String: Any] {
                    Console.shared.log("Payload:\(data)\n")
                    let success = self.parser.asBoolean(data["success"])?.boolValue ?? false
                    if success {
                        self.completion?(data, error)
                    } else {
                        if let error = error {
                            self.completion?(nil, error)
                        } else {
                            let className = String(describing: type(of: self))
                            let error = NSError(domain: "\(className).response.fail", code: 0, userInfo: data)
                            ErrorLogging.shared?.log(error)
                            self.completion?(nil, error)
                        }
                    }
                } else {
                    if let error = error {
                        self.completion?(nil, error)
                    } else {
                        let className = String(describing: type(of: self))
                        let error = NSError(domain: "\(className).response.invalid", code: 0, userInfo: nil)
                        ErrorLogging.shared?.log(error)
                        self.completion?(nil, error)
                    }
                }
            } else {
                self?.completion?(nil, error)
            }
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                self.file = nil
                ErrorLogging.shared?.log(error)
                self.completion?(nil, error)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async { [weak self] in
            self?.progress?(Float(totalBytesSent) / Float(totalBytesExpectedToSend))
        }
    }
}
