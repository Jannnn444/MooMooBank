//
//  EntryView.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/3/3.
//

import SwiftUI

struct LevelConfig {
    let level: Int
    let tapsRequired: Int
    let size: CGFloat
    let color: Color
    let label: String
    let glowRadius: CGFloat
}

let levelConfigs: [LevelConfig] = [
    LevelConfig(level: 1, tapsRequired: 0,   size: 14, color: .cyan,   label: "I",   glowRadius: 4),
    LevelConfig(level: 2, tapsRequired: 5,   size: 15, color: .green,  label: "II",  glowRadius: 6),
    LevelConfig(level: 3, tapsRequired: 10,  size: 16, color: .yellow, label: "III", glowRadius: 8),
    LevelConfig(level: 4, tapsRequired: 30,  size: 17, color: .orange, label: "IV",  glowRadius: 10),
    LevelConfig(level: 5, tapsRequired: 50,  size: 25, color: .red,    label: "V",   glowRadius: 13),
    LevelConfig(level: 6, tapsRequired: 100, size: 30, color: .purple, label: "VI",  glowRadius: 15),
    LevelConfig(level: 7, tapsRequired: 200, size: 40, color: .pink,   label: "VII", glowRadius: 20),
    LevelConfig(level: 8, tapsRequired: 500, size: 50, color: .white,  label: "MAX", glowRadius: 28),
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

// MARK: - Floating Atom View
struct AtomBubble: View {
    let atom: Atom
    let onTap: () -> Void
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var pulse: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var showTapCount: Bool = false
    
    var body: some View {
        ZStack {
            // Outer glow ring for high levels
            if atom.level >= 5 {
                Circle()
                    .stroke(atom.color.opacity(0.3), lineWidth: 2)
                    .frame(width: atom.size + 14, height: atom.size + 14)
                    .scaleEffect(pulse ? 1.2 : 0.95)
            }
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [atom.color.opacity(0.95), atom.color.opacity(0.3)],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: atom.size
                    )
                )
                .frame(width: atom.size, height: atom.size)
                .shadow(color: atom.color.opacity(0.7), radius: pulse ? atom.glowRadius * 1.5 : atom.glowRadius)
                .scaleEffect(pulse ? 1.08 : 1.0)
            
            VStack(spacing: 1) {
                Text(atom.label)
                    .font(.system(size: max(atom.size * 0.28, 6), weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                // Tap progress bar
                if let remaining = atom.tapsToNextLevel {
                    let next = levelConfigs.first(where: { $0.tapsRequired > atom.taps })
                    let prev = levelConfigs.last(where: { $0.tapsRequired <= atom.taps })
                    let total = (next?.tapsRequired ?? atom.taps) - (prev?.tapsRequired ?? 0)
                    let done = total - remaining
                    let progress = total > 0 ? CGFloat(done) / CGFloat(total) : 1.0
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: atom.size * 0.6, height: 3)
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: atom.size * 0.6 * progress, height: 3)
                    }
                }
            }
            
            // Tap count popup
            if showTapCount {
                Text("+1")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .offset(y: -atom.size * 0.8)
                    .transition(.asymmetric(
                        insertion: .offset(y: 0).combined(with: .opacity),
                        removal: .offset(y: -10).combined(with: .opacity)
                    ))
            }
        }
        .scaleEffect(scale)
        .offset(x: offsetX, y: offsetY)                          // ✅ applies float drift
        .position(x: atom.position.x, y: atom.position.y)        // ✅ places atom on screen
        .onAppear {
            let duration = Double.random(in: 2.5...4.0)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                offsetY = CGFloat.random(in: -18...18)
                offsetX = CGFloat.random(in: -12...12)
                pulse = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.35)) { scale = 1.5 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { scale = 1.0 }
            }
            withAnimation { showTapCount = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { showTapCount = false }
            }
            onTap()
        }
    }
}

// MARK: - Entry View
struct EntryView: View {
    @State private var atoms: [Atom] = []
    @State private var isAtomExploded: Bool = false
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false
    
    @State private var isShowLevelMenu: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - 1. Atom top-left counter reception
            
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
            
            // MARK: - 3. UI overlay
            VStack(spacing: 16) {
                
                Text("Fortune")
                    .foregroundStyle(.white)
                    .fontDesign(.monospaced)
                    .font(.title2)
                
                Button {
                    spawnAtom()
                } label: {
                    Image("coin")
                        .resizable()
                        .frame(width: 150, height: 150)
                }
                
                Text("Tap atoms to grow · Coin to spawn")
                    .foregroundStyle(.gray)
                    .fontDesign(.monospaced)
                    .font(.caption)
                
                
                // MARK - Divider Display Level
                Divider().overlay(.gray)
                
                    if isShowLevelMenu {
                        // Level Legend Display Toggle
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(levelConfigs, id: \.level) { config in
                                    VStack(spacing: 3) {
                                        Circle()
                                            .fill(config.color)
                                            .frame(width: 10, height: 10)
                                        Text("Lv\(config.level)")
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
                
                
                if showToast {
                    Text(toastMessage)
                        .foregroundStyle(.yellow)
                        .fontDesign(.monospaced)
                        .font(.caption)
                        .transition(.opacity.combined(with: .scale))
                }
                
            }.ignoresSafeArea()
            
            // MARK: - Toggle Menu
            VStack {
                Spacer()
                
                HStack {
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
                            
                            Image("menu")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                        }
                    }.offset(x: -30)
                }
                
            }
        }
    }
    
    func spawnAtom() {
        // CGFloat restricted area for atom-spawning
        isAtomExploded = true
        let screen = UIScreen.main.bounds // full screen
        let atom = Atom(position: CGPoint(
            x: CGFloat.random(in: 40...(screen.width - 40)),
            y: CGFloat.random(in: 60...(screen.height - 60))
        ))
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


