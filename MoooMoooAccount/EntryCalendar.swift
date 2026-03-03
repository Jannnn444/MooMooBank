//
//  EntryCalendar.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/3/3.
//

import SwiftUI

struct EntryCalendar: View {
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var days: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
                
        else { return [] }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        let leadingBlanks = firstWeekday - 1 // offset for first day position
        
        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in 1...daysInMonth {
            var components = calendar.dateComponents([.year, .month], from: currentDate)
            components.day = day
            days.append(calendar.date(from: components))
        }
        return days
    }
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack {
                
                Button {
                    currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }

                Spacer()
                
                // MARK: - Shows the calendar
                Text(monthYearTitle)
                    .font(.headline)
                    .fontDesign(.monospaced)
                
                Spacer()
                
                Button {
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }.padding(.horizontal)
            
            VStack(spacing: 8) {
                // MARK: - Weekday Headers
                LazyVGrid(columns: columns) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Day Cells
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                        if let date {
                            let dayNumber = calendar.component(.day, from: date)
                            
                            ZStack {
                                if isToday(date) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 36, height: 36)
                                }
                                
                                Text("\(dayNumber)")
                                    .font(.system(size: 15))
                                    .foregroundStyle(isToday(date) ? .white : .primary)
                                    .fontWeight(isToday(date) ? .bold : .regular)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                        } else {
                            Color.clear
                                .frame(height: 40)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
    }
}
