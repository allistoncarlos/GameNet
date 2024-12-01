//
//  ServerDriven+View.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/11/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func renderChildren(components: [Element]) -> some View {
        ForEach(components) { component in
            switch component.componentType {
            case Components.vstack.rawValue:
                if let properties = component.properties {
                    if let spacing = properties.spacing {
                        AnyView(VStack(spacing: spacing) {
                            if let elements = component.elements {
                                renderChildren(components: elements)
                            }
                        })
                    }
                } else {
                    AnyView(VStack {
                        if let elements = component.elements {
                            renderChildren(components: elements)
                        }
                    })
                }
            case Components.scrollView.rawValue:
                AnyView(ScrollView {
                    if let elements = component.elements {
                        renderChildren(components: elements)
                    }
                })
                
            case Components.spacer.rawValue:
                AnyView(Spacer())

            case Components.text.rawValue:
                if let properties = component.properties,
                   let value = properties.value {
                    AnyView(Text(value))
                }

            case Components.dashboardText.rawValue:
                if let properties = component.properties,
                   let value = properties.value {
                    AnyView(DashboardText(value))
                }

            case Components.image.rawValue:
                if let properties = component.properties,
                   let url = properties.url {
                    AnyView(AsyncImage(url: url))
                }

            case Components.card.rawValue:
                if let properties = component.properties,
                   let title = properties.title,
                   let elements = component.elements {
                    AnyView(Card(
                        title: title,
                        color: Color.secondaryCardBackground, // Ajustar para mapear a cor do backend
                        elements: elements
                    ))
                }

            case Components.hstack.rawValue:
                if let properties = component.properties {
                    if let spacing = properties.spacing {
                        AnyView(HStack(spacing: spacing) {
                            if let elements = component.elements {
                                renderChildren(components: elements)
                            }
                        })
                    }
                } else {
                    AnyView(HStack {
                        if let elements = component.elements {
                            renderChildren(components: elements)
                        }
                    })
                }

            default:
                AnyView(EmptyView())
            }
        }
    }
}
