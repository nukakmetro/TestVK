//
//  ImagesLoader.swift
//  Test
//
//  Created by surexnx on 01.03.2025.
//

import Foundation
import UIKit

enum ImagesLoaderError: Error {
    case downloadingError
    case loadingError
    case convertingError
}

/// Класс для загрузки картинки. Имеет встроенное кеширование
final class ImageLoader {

    // MARK: - Private properties

    private let cache = NSCache<NSString, UIImage>()

    // MARK: - Internal methods

    /// Метод асинхроной загрузки картинок
    /// Перед загрузкой проверяет наличие в кеше
    func asyncFetchImage(url: URL, completion: @escaping (Result<UIImage, ImagesLoaderError>) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }

            if let image = getImageData(forKey: url.absoluteString) {
                DispatchQueue.main.async {
                    return completion(.success(image))
                }
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard
                    let self,
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil
                else {                DispatchQueue.main.async {

                    completion(.failure(.downloadingError))
                }
                    return
                }
                guard 200 ..< 300 ~= response.statusCode else {
                    DispatchQueue.main.async {
                        completion(.failure(.loadingError))
                    }
                    return
                }
                guard let image = convertDataToUIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(.convertingError))
                    }
                    return
                }

                setImageData(image, forKey: url.absoluteString)

                DispatchQueue.main.async {
                    completion(.success(image))
                }
            }.resume()
        }
    }

    // MARK: - Private methods

    /// Метод для получения изображения (в виде Data) из кеша
    private func getImageData(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString) as UIImage?
    }

    /// Метод для сохранения изображения в кеш (в виде Data)
    private func setImageData(_ image: UIImage, forKey key: String) {
        cache.setObject(image as UIImage, forKey: key as NSString)
    }

    /// Метод для преобразования UIImage в Data
    private func convertUIImageToData(image: UIImage) -> Data? {
        return image.pngData() // Или используйте jpegData(compressionQuality:) для сжатия
    }

    /// Метод для преобразования Data в UIImage
    private func convertDataToUIImage(data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
