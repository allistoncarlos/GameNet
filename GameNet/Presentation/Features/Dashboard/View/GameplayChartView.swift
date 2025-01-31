//
//  GameplayChartView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 18/06/23.
//

import Charts
import SwiftUI

// MARK: - GameplayChartView

struct GameplayChartView: View {

    // MARK: Internal

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
            ScrollViewReader { scrollPosition in
                ScrollView(.horizontal) {
                    Chart {
                        ForEach($data.wrappedValue.sorted(by: { $0.sortDate < $1.sortDate })) { shape in
                            BarMark(
                                x: .value("Shape Type", shape.type),
                                y: .value("Total Count", shape.count)
                            )
                        }
                    }
                    .foregroundColor(.main)
                    .frame(width: UIScreen.main.bounds.size.width < CGFloat($data.count) * barWidth ? CGFloat($data.count) * barWidth : UIScreen.main.bounds.size.width)
                    .padding()
                    .id(10001)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollPosition.scrollTo(10001, anchor: .topTrailing)
                }
            }
        }
    }

    // MARK: Private

    @State private var selectedPeriod = 0

}

// MARK: - Previews

#Preview("Dark Mode") {
    GameplayChartView(
        data: .constant([
            .init(type: "Cube", sortDate: Date(), count: 5),
            .init(type: "Sphere", sortDate: Date(), count: 4),
            .init(type: "Pyramid", sortDate: Date(), count: 4),
            .init(type: "Cube2", sortDate: Date(), count: 5),
            .init(type: "Sphere2", sortDate: Date(), count: 4),
            .init(type: "Pyramid2", sortDate: Date(), count: 4),
            .init(type: "Pyramid3", sortDate: Date(), count: 4),
            .init(type: "Pyramid4", sortDate: Date(), count: 4)
        ]),
        recentRegister: .constant(UUID())
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    GameplayChartView(
        data: .constant([
            .init(type: "Cube", sortDate: Date(), count: 5),
            .init(type: "Sphere", sortDate: Date(), count: 4),
            .init(type: "Pyramid", sortDate: Date(), count: 4),
            .init(type: "Cube2", sortDate: Date(), count: 5),
            .init(type: "Sphere2", sortDate: Date(), count: 4),
            .init(type: "Pyramid2", sortDate: Date(), count: 4),
            .init(type: "Pyramid3", sortDate: Date(), count: 4),
            .init(type: "Pyramid4", sortDate: Date(), count: 4)
        ]),
        recentRegister: .constant(UUID())
    ).preferredColorScheme(.light)
}
