//
//  ContentView.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/2/12.
//

import SwiftUI

// MARK: - Data Models
struct Transaction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let category: String
    let amount: Double
    let date: Date
    let isIncome: Bool
    
    var formattedAmount: String {
        let sign = isIncome ? "+" : "-"
        return "\(sign)$\(String(format: "%.0f", abs(amount)))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// MARK: - Sample Data
extension Transaction {
    static let sampleData: [Transaction] = [
        Transaction(icon: "cart.fill", title: "Grocery", category: "Food", amount: 1280, date: Date(), isIncome: false),
        Transaction(icon: "briefcase.fill", title: "Salary", category: "Income", amount: 52000, date: Date(), isIncome: true),
        Transaction(icon: "cup.and.saucer.fill", title: "Coffee Shop", category: "Drinks", amount: 185, date: Date().addingTimeInterval(-86400), isIncome: false),
        Transaction(icon: "train.side.front.car", title: "MRT Pass", category: "Transport", amount: 1280, date: Date().addingTimeInterval(-86400), isIncome: false),
        Transaction(icon: "film.fill", title: "Netflix", category: "Entertainment", amount: 390, date: Date().addingTimeInterval(-172800), isIncome: false),
        Transaction(icon: "bolt.fill", title: "Electricity", category: "Bills", amount: 2350, date: Date().addingTimeInterval(-172800), isIncome: false),
        Transaction(icon: "gift.fill", title: "Freelance", category: "Income", amount: 8500, date: Date().addingTimeInterval(-259200), isIncome: true),
        Transaction(icon: "fork.knife", title: "Din Tai Fung", category: "Food", amount: 960, date: Date().addingTimeInterval(-345600), isIncome: false),
    ]
}

// MARK: - Theme Colors
struct AppTheme {
    static let background = Color(red: 0.96, green: 0.95, blue: 0.93)  // Warm cream
    static let card = Color.white
    static let accent = Color(red: 0.20, green: 0.36, blue: 0.35)      // Deep teal
    static let accentLight = Color(red: 0.55, green: 0.78, blue: 0.72) // Soft mint
    static let expense = Color(red: 0.85, green: 0.30, blue: 0.28)     // Warm red
    static let income = Color(red: 0.22, green: 0.70, blue: 0.55)      // Fresh green
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.15) // Sacred fire :D
    static let textSecondary = Color(red: 0.55, green: 0.53, blue: 0.50)
    static let divider = Color(red: 0.90, green: 0.88, blue: 0.85)
}

// MARK: - Content View
struct ContentView: View {
    @State private var selectedPeriod: TimePeriod = .month
    @State private var transactions = Transaction.sampleData
    @State private var showingAddSheet = false
    
    private var totalBalance: Double {
        transactions.reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    // Group transactions by date
    private var groupedTransactions: [(String, [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: transaction.date)
        }
        return grouped.sorted { pair1, pair2 in
            guard let d1 = pair1.value.first?.date, let d2 = pair2.value.first?.date else { return false }
            return d1 > d2
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    balanceCard
                    incomeExpenseRow
                    periodPicker
                    transactionsList
                }
                .padding(.bottom, 100)
            }
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView { newTransaction in
                withAnimation(.spring(response: 0.4)) {
                    transactions.insert(newTransaction, at: 0)
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Moo Moo")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
                Text("Account Book 🐄")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            
            // Profile avatar
            Circle()
                .fill(AppTheme.accent.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.accent)
                )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 12) {
            Text("Total Balance")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
            
            Text("$\(String(format: "%.0f", totalBalance))")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
            
            Text("February 2026")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 16, y: 8)
        )
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    // MARK: - Income / Expense Summary Row
    private var incomeExpenseRow: some View {
        HStack(spacing: 16) {
            // Income card
            summaryCard(
                title: "Income",
                amount: totalIncome,
                icon: "arrow.down.left",
                color: AppTheme.income
            )
            // Expense card
            summaryCard(
                title: "Expense",
                amount: totalExpense,
                icon: "arrow.up.right",
                color: AppTheme.expense
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private func summaryCard(title: String, amount: Double, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                Text("$\(String(format: "%.0f", amount))")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
    
    // MARK: - Period Picker
    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedPeriod == period
                            ? Capsule().fill(AppTheme.accent)
                            : Capsule().fill(Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppTheme.card)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    // MARK: - Transactions List
    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transactions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 24)
            
            ForEach(Array(groupedTransactions.enumerated()), id: \.offset) { _, group in
                VStack(alignment: .leading, spacing: 8) {
                    // Date header
                    Text(group.0)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 24)
                    
                    // Transaction rows inside a card
                    VStack(spacing: 0) {
                        ForEach(Array(group.1.enumerated()), id: \.element.id) { index, transaction in
                            transactionRow(transaction)
                            
                            if index < group.1.count - 1 {
                                Divider()
                                    .background(AppTheme.divider)
                                    .padding(.leading, 68)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.card)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.top, 24)
    }
    
    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 14) {
            // Icon
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    (transaction.isIncome ? AppTheme.income : AppTheme.accent)
                        .opacity(0.1)
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(transaction.isIncome ? AppTheme.income : AppTheme.accent)
                )
            
            // Title & Category
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text(transaction.category)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(transaction.isIncome ? AppTheme.income : AppTheme.expense)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Floating Add Button
    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(AppTheme.accent)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
                )
        }
    }
}

// MARK: - Add Transaction Sheet
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var selectedCategory = "Food"
    
    let categories = [
        ("Food", "cart.fill"),
        ("Transport", "train.side.front.car"),
        ("Drinks", "cup.and.saucer.fill"),
        ("Bills", "bolt.fill"),
        ("Entertainment", "film.fill"),
        ("Income", "briefcase.fill"),
    ]
    
    var onAdd: (Transaction) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Toggle Income / Expense
                        HStack(spacing: 0) {
                            toggleButton(title: "Expense", isSelected: !isIncome) {
                                withAnimation { isIncome = false }
                            }
                            toggleButton(title: "Income", isSelected: isIncome) {
                                withAnimation { isIncome = true }
                            }
                        }
                        .padding(4)
                        .background(
                            Capsule()
                                .fill(AppTheme.card)
                        )
                    
                        // Amount Input
                        VStack(spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("$")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                TextField("0", text: $amount)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.card)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                        )
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("What was this for?", text: $title)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.card)
                                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                                )
                        }
                        
                        // Category Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(categories, id: \.0) { category in
                                    categoryButton(name: category.0, icon: category.1)
                                }
                            }
                        }
                        
                        // Save Button
                        Button {
                            guard let amountValue = Double(amount), !title.isEmpty else { return }
                            let icon = categories.first { $0.0 == selectedCategory }?.1 ?? "circle.fill"
                            let transaction = Transaction(
                                icon: icon,
                                title: title,
                                category: selectedCategory,
                                amount: amountValue,
                                date: Date(),
                                isIncome: isIncome
                            )
                            onAdd(transaction)
                            dismiss()
                        } label: {
                            Text("Save Transaction")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppTheme.accent)
                                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, y: 6)
                                )
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
    
    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected
                    ? Capsule().fill(AppTheme.accent)
                    : Capsule().fill(Color.clear)
                )
        }
    }
    
    private func categoryButton(name: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = name
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(name)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(selectedCategory == name ? .white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedCategory == name ? AppTheme.accent : AppTheme.card)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            )
        }
    }
}



#Preview {
    ContentView()
}
