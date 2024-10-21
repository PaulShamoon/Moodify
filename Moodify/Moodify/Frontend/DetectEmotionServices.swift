//
//  DetectEmotionServices.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 10/19/24.
//

func detectMood(from image: UIImage, serverURL: String, completion: @escaping (String?, String?) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.9) else {  // Use higher quality so this way the model can provide a more accurate mood detection
        completion(nil, "Failed to convert image to data")
        return
    }

    var request = URLRequest(url: URL(string: serverURL)!)
    request.httpMethod = "POST"
    request.timeoutInterval = 60  // Avoid timeouts
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body

    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Network Error: \(error.localizedDescription)")  // Log the error for debugging for error handling
                completion(nil, "Network Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, "Invalid response from server")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let mood = json["mood"] as? String else {
                completion(nil, "Failed to decode server response")
                return
            }

            print("Detected Mood: \(mood)")  // Log detected mood
            completion(mood, nil)
        }
    }.resume()
}
