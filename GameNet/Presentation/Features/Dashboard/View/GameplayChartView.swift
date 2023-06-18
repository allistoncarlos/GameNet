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
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    // MARK: Private

    @State private var selectedPeriod = 0

}

// MARK: - GameplayChartView_Previews

struct GameplayChartView_Previews: PreviewProvider {
    static var previews: some View {
        GameplayChartView(data: .constant([
            .init(type: "Cube", sortDate: Date(), count: 5),
            .init(type: "Sphere", sortDate: Date(), count: 4),
            .init(type: "Pyramid", sortDate: Date(), count: 4),
            .init(type: "Cube2", sortDate: Date(), count: 5),
            .init(type: "Sphere2", sortDate: Date(), count: 4),
            .init(type: "Pyramid2", sortDate: Date(), count: 4),
            .init(type: "Pyramid3", sortDate: Date(), count: 4),
            .init(type: "Pyramid4", sortDate: Date(), count: 4)
        ]))
    }
}
