//
//  Habit.swift
//  habify
//
//  Created by I Putu Wahyu Eka Putra Sedana on 24/08/25.
//

import Foundation

struct Habit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
}
