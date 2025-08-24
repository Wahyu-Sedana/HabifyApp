//
//  HabitService.swift
//  habify
//
//  Created by I Putu Wahyu Eka Putra Sedana on 24/08/25.
//

import Foundation

class HabitService {
    func fetchHabit(completion: @escaping (Result<[Habit], Error>) -> Void) {
        guard let url = URL(string: APIConstans.baseURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let habits = try JSONDecoder().decode([Habit].self, from: data)
                        completion(.success(habits))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
    }
}
