
import SwiftUI

class mooManager {
    @State var isUpdated: Bool = false
    @State var isSynced: Bool = false
    @State private var transactions = Transaction.sampleData
    @State private var showingAddSheet = false
    @State var resultAfterMoneyPunishment = Transaction.sampleData
    
    private var totalBalance: Double {
        transactions.reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    init(){
    }
    

}
