//
//  HabitCard.swift
//  habify
//
//  Created by I Putu Wahyu Eka Putra Sedana on 24/08/25.
//

import SwiftUI

struct HabitCard: View {
    var habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            }
            
            Text(habit.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("From \(habit.startDate, style: .date) to \(habit.endDate, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
