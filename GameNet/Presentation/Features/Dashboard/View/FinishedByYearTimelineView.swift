//
//  FinishedByYearTimelineView.swift
//  GameNet
//
//  Created by AI Assistant
//

import SwiftUI
import GameNet_Network

// MARK: - FinishedByYearTimelineView

struct FinishedByYearTimelineView: View {
    
    // MARK: Internal
    
    let finishedGamesByYear: [FinishedGameByYearTotal]
    let onYearTapped: (FinishedGameByYearTotal) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Finalizados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }
                
                LazyVStack(spacing: 0) {
                    ForEach(Array(finishedGamesByYear.enumerated()), id: \.element.year) { index, finishedGame in
                        TimelineItemView(
                            finishedGame: finishedGame,
                            isLeft: index % 2 == 0,
                            isFirst: index == 0,
                            isLast: index == finishedGamesByYear.count - 1,
                            onTapped: {
                                onYearTapped(finishedGame)
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - TimelineItemView

struct TimelineItemView: View {
    
    // MARK: Internal
    
    let finishedGame: FinishedGameByYearTotal
    let isLeft: Bool
    let isFirst: Bool
    let isLast: Bool
    let onTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            if isLeft {
                // Conteúdo à esquerda
                contentView
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Timeline central
                timelineView
                
                // Espaço vazio à direita
                Spacer()
                    .frame(maxWidth: .infinity)
            } else {
                // Espaço vazio à esquerda
                Spacer()
                    .frame(maxWidth: .infinity)
                
                // Timeline central
                timelineView
                
                // Conteúdo à direita
                contentView
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 80)
    }
    
    // MARK: Private
    
    private var contentView: some View {
        Button(action: onTapped) {
            VStack(spacing: 4) {
                Text(String(finishedGame.year))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(finishedGame.total) jogos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timelineView: some View {
        VStack(spacing: 0) {
            // Linha superior (apenas se não for o primeiro)
            if !isFirst {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: isLast ? 68 : 20)
            }
            
            // Círculo central
            Circle()
                .fill(Color.accentColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Linha inferior (apenas se não for o último)
            if !isLast {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: isFirst ? 68 : 48)
            }
        }
        .frame(width: 20)
    }
}

// MARK: - Preview

#Preview("Timeline View") {
    let sampleData = [
        FinishedGameByYearTotal(year: 2024, total: 15),
        FinishedGameByYearTotal(year: 2023, total: 12),
        FinishedGameByYearTotal(year: 2022, total: 8),
        FinishedGameByYearTotal(year: 2021, total: 10),
        FinishedGameByYearTotal(year: 2020, total: 6),
        FinishedGameByYearTotal(year: 2019, total: 4),
        FinishedGameByYearTotal(year: 2018, total: 7),
        FinishedGameByYearTotal(year: 2017, total: 3),
        FinishedGameByYearTotal(year: 2016, total: 5),
        FinishedGameByYearTotal(year: 2015, total: 2)
    ]
    
    FinishedByYearTimelineView(
        finishedGamesByYear: sampleData,
        onYearTapped: { _ in }
    )
    .preferredColorScheme(.dark)
}

#Preview("Timeline View Light") {
    let sampleData = [
        FinishedGameByYearTotal(year: 2024, total: 15),
        FinishedGameByYearTotal(year: 2023, total: 12),
        FinishedGameByYearTotal(year: 2022, total: 8),
        FinishedGameByYearTotal(year: 2021, total: 10),
        FinishedGameByYearTotal(year: 2020, total: 6)
    ]
    
    FinishedByYearTimelineView(
        finishedGamesByYear: sampleData,
        onYearTapped: { _ in }
    )
    .preferredColorScheme(.light)
}

