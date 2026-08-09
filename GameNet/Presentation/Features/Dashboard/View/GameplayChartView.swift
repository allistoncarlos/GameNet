//
//  GameplayChartView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 18/06/23.
//

import Charts
import SwiftUI

struct GameplayChartView: View {

    @Binding var data: [BarShape]
    @Binding var recentRegister: UUID?
    let barWidth: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Picker("Period", selection: $selectedPeriod) {
                Text("D").tag(0)
                Text("S").tag(1)
                Text("M").tag(2)
                Text("6M").tag(3)
                Text("A").tag(4)
            }
            .pickerStyle(.segmented)
            GeometryReader { geometry in
                let chartWidth = max(
                    geometry.size.width,
                    CGFloat(data.count) * barWidth
                )

                ScrollViewReader { scrollPosition in
                    ScrollView(.horizontal) {
                        Chart {
                            ForEach(data.sorted(by: { $0.sortDate < $1.sortDate })) { shape in
                                BarMark(
                                    x: .value("Shape Type", shape.type),
                                    y: .value("Total Count", shape.count)
                                )
                            }
                        }
                        .foregroundColor(.main)
                        .frame(width: chartWidth)
                        .padding()
                        .id(10001)
                    }
                    .scrollIndicators(.hidden)
                    .onAppear {
                        scrollPosition.scrollTo(10001, anchor: .topTrailing)
                    }
                }
            }
            .frame(height: 220)
        }
    }

    @State private var selectedPeriod = 0
}
