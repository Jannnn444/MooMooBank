//
//  EntryView.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/3/3.
//

import SwiftUI
import Foundation

struct LevelConfig {
    let level: Int
    let tapsRequired: Int
    let size: CGFloat
    let color: Color
    let label: String
    let glowRadius: CGFloat
}

let levelConfigs: [LevelConfig] = [
    LevelConfig(level: 1, tapsRequired: 0,   size: 14, color: .yellow,   label: "yellow",   glowRadius: 4),
    LevelConfig(level: 2, tapsRequired: 5,   size: 15, color: .green,  label: "green",  glowRadius: 6),
    LevelConfig(level: 3, tapsRequired: 10,  size: 16, color: .yellow, label: "yellow", glowRadius: 8),
    LevelConfig(level: 4, tapsRequired: 30,  size: 17, color: .orange, label: "orange",  glowRadius: 10),
    LevelConfig(level: 5, tapsRequired: 50,  size: 25, color: .red,    label: "red",   glowRadius: 13),
    LevelConfig(level: 6, tapsRequired: 100, size: 30, color: .purple, label: "purple",  glowRadius: 15),
    LevelConfig(level: 7, tapsRequired: 200, size: 40, color: .pink,   label: "pink", glowRadius: 20),
    LevelConfig(level: 8, tapsRequired: 500, size: 50, color: .white,  label: "white", glowRadius: 28),
]

func configForTaps(_ taps: Int) -> LevelConfig {
    levelConfigs.last(where: { taps >= $0.tapsRequired }) ?? levelConfigs[0]
}

// MARK: - Atom Model
struct Atom: Identifiable {
    let id = UUID()
    var taps: Int = 0
    var position: CGPoint
    
    var config: LevelConfig { configForTaps(taps) }
    var level: Int { config.level }
    var size: CGFloat { config.size }
    var color: Color { config.color }
    var label: String { config.label }
    var glowRadius: CGFloat { config.glowRadius }
    
    var tapsToNextLevel: Int? {
        let next = levelConfigs.first(where: { $0.tapsRequired > taps })
        return next.map { $0.tapsRequired - taps }
    }
}


// MARK: - Entry View
struct EntryView: View {
    @State private var atoms: [Atom] = []
    @State private var isAtomExploded: Bool = false
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false
    
    @State private var isShowLevelMenu: Bool = false
    @State private var isFirstTapped: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - 1. Atom top-left bar counter reception
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(.cyan).frame(width: 15, height: 15)
                        
                        Text("Atoms :\(atoms.count)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                    .padding(.top, 56)
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                Spacer()
            }
            
            
            Button {
                spawnAtom()
            } label: {
                Image("coin")
                    .resizable()
                    .frame(width: 150, height: 150)
            }
            
            // MARK: - 2. Atoms layer
            if isAtomExploded {
                GeometryReader { geo in
                    ForEach(atoms) { atom in
                        AtomBubble(atom: atom) {
                            tapAtom(id: atom.id)
                        }
                    }
                }
                .ignoresSafeArea()
            }
            
            if isFirstTapped == false {
                // MARK: - 3. Greeting text overlay
                VStack(spacing: 16) {
                    Text("Fortune")
                        .foregroundStyle(.white)
                        .fontDesign(.monospaced)
                        .font(.title2)
                    
                    Text("Tap atoms to grow · Coin to spawn")
                        .foregroundStyle(.gray)
                        .fontDesign(.monospaced)
                        .font(.caption)
                    
                    
                    // MARK - Divider Display Level
                    Divider().overlay(.gray)
                
            }
        }
            
            // MARK: - Toggle Menu
            VStack {
                Spacer()
                
                if showToast {
                    Text(toastMessage)
                        .foregroundStyle(.yellow)
                        .fontDesign(.monospaced)
                        .font(.caption)
                        .transition(.opacity.combined(with: .scale))
                }
                
                HStack {
                    if isShowLevelMenu {
                        // Level Legend Display Toggle
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(levelConfigs, id: \.level) { config in
                                    VStack(spacing: 3) {
                                        Circle()
                                            .fill(config.color)
                                            .frame(width: 10, height: 10)
                                        Text("\(config.label)")
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundStyle(.gray)
                                        Text(config.tapsRequired == 0 ? "start" : "\(config.tapsRequired)t")
                                            .font(.system(size: 7, design: .monospaced))
                                            .foregroundStyle(.gray.opacity(0.6))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                 
                    Spacer()
                    
                    Button {
                        isShowLevelMenu.toggle()
                    } label: {
                        ZStack {
                            Text("")
                                .padding()
                                .frame(width: 70, height: 70)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(12)
                                .padding(.bottom, 10)
                            
                            Image("menu")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                                .padding(.bottom, 10)
                        }.ignoresSafeArea()
                    }
                }
            }.ignoresSafeArea()
        }.ignoresSafeArea()
    }
    
    /* Easier Atom Creater
    
    func spawnAtom() {
        // CGFloat restricted area for atom-spawning
        isFirstTapped = true
        isAtomExploded = true
        let screen = UIScreen.main.bounds // full screen
        let atom = Atom(position: CGPoint(
            x: CGFloat.random(in: 0...(screen.width )),
            y: CGFloat.random(in: 0...(screen.height ))
        ))
        withAnimation(.spring()) { atoms.append(atom) }
    }
     */
    
    /* Atom Creater - Divided Area */
    func spawnAtom() {
        isFirstTapped = true
        isAtomExploded = true

        let screen = UIScreen.main.bounds
        let cols = 3
        let rows = 4

        let cellW = (screen.width  ) / CGFloat(cols)
        let cellH = (screen.height ) / CGFloat(rows)

        // Count how many atoms are already in each zone
        var zoneCounts = Array(repeating: 0, count: cols * rows)
        for atom in atoms {
            let col = Int((atom.position.x ) / cellW).clampedTo(0...(cols - 1))
            let row = Int((atom.position.y ) / cellH).clampedTo(0...(rows - 1))
            zoneCounts[row * cols + col] += 1
        }

        // Pick the zone with fewest atoms (ties broken randomly)
        let minCount = zoneCounts.min() ?? 0
        let candidates = zoneCounts.indices.filter { zoneCounts[$0] == minCount }
        let chosen = candidates.randomElement()!

        let chosenRow = chosen / cols
        let chosenCol = chosen % cols

        let randX = CGFloat.random(in: 10...(cellW - 10))
        let randY = CGFloat.random(in: 10...(cellH - 10))
        let x =  CGFloat(chosenCol) * cellW + randX
        let y =  CGFloat(chosenRow) * cellH + randY


        let atom = Atom(position: CGPoint(x: x, y: y))
        withAnimation(.spring()) { atoms.append(atom) }
    }
    
    func tapAtom(id: UUID) {
        guard let index = atoms.firstIndex(where: { $0.id == id }) else { return }
        let oldLevel = atoms[index].level
        atoms[index].taps += 1
        let newLevel = atoms[index].level
        
        if newLevel > oldLevel {
            let isMax = newLevel == levelConfigs.last?.level
            toastMessage = isMax ? "⚡ MAXIMUM POWER!" : "⬆️ Level \(newLevel) reached!"
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { showToast = false }
            }
        }
    }
}

extension Int {
    func clampedTo(_ range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// spontaneuos help card -> CAUTION! This will really change your game totally
// it's by chance to get help by alien?
// a moomoo cow planet       (black and white)
// a yogurt planet           (white vibe)
// a demoniac ruling planet  (hell vibe)


// NOTE:
/*
 1. The elements will be created:
 Hydrogen (H): approximately 75%,
 Helium (He): approximately 25%,
 Lithium (Li): trace amounts (roughly one part in ten billion)
 
 2. What's the first happening after the big bang
 
 
 建議的遊戲流程
 
 第一階段：Big Bang
 按下按鈕後，畫面全紅、爆炸特效，右下角溫度顯示極高數值（例如 10¹² K），畫面上飛散的是夸克粒子（小點點），無法被捕捉。
 第二階段：冷卻中
 畫面從紅→橘→黃，溫度數字持續下降，夸克開始自動聚合成 p（質子） 和 n（中子） 的符號，玩家還不能操作。
 第三階段：核合成視窗（黃金20秒）
 ⭐ 這裡是玩家的互動時機！
 畫面出現倒數計時（例如5秒），玩家需要快速點擊或搖一搖，將 p 和 n 撞在一起，合成 He核。
 沒來得及配對的就剩下 H。
 → 這樣玩家自然就會得到約 75% H、25% He 的結果，非常符合現實！
 第四階段：霧散、電漿冷卻
 畫面轉灰霧，溫度繼續下降，霧慢慢散開，飄著 H 和 He 的原子核符號。
 第五階段：38萬年後 — 原子誕生
 畫面一片星空，電子（e⁻）開始飄入，玩家再次搖一搖或點擊，讓電子被原子核捕獲，完成完整的 H atom 和 He atom。
 
 
 溫度計的設計建議
 溫度     顏色       狀態
 10¹²K   深紅      夸克混沌
 10¹⁰K   橘紅      質子中子形成
 10⁹K     黃       核合成開始
 10⁴K    灰藍      電漿霧散
 3000K   深藍星空   原子誕生
 
 
 
 更震撼的是
 你身體裡的氫原子，是138億年前大霹靂直接產生的，一路漂流到今天，進入了你的身體。
 你身體裡的碳、氧等較重元素，則是某顆已經死亡的恆星內部核融合製造出來的，在恆星爆炸（超新星）時噴散到宇宙中，最終聚集成地球，再變成你。
 所以有句話說：
 
 "We are all made of stardust."
 我們都是星塵組成的。
 
 
 大霹靂 → 原子 → 星塵 → 地球 → 生命 → 恐龍 → 滅絕 → 靈長類 → 人類 → 城市文明
 你的遊戲概念真的很有創意！從大霹靂→原子→星塵→地球生命→人類文明，整個宇宙史串成一個遊戲，敘事弧線非常完整又有詩意！🌌
 
 
 
 */


