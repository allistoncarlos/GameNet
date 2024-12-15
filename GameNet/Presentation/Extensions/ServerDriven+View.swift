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
                renderVStack(component)
                
            case Components.scrollView.rawValue:
                renderScrollView(component)
                
            case Components.navigationLink.rawValue:
                renderNavigationLink(component)
                
            case Components.spacer.rawValue:
                Spacer()
                
            case Components.text.rawValue:
                renderText(component)
                
            case Components.dashboardText.rawValue:
                renderDashboardText(component)
                
            case Components.subtitle.rawValue:
                renderSubtitle(component)
                
            case Components.image.rawValue:
                renderImage(component)
                
            case Components.card.rawValue:
                renderCard(component)
                
            case Components.hstack.rawValue:
                renderHStack(component)
                
            case Components.carouselCover.rawValue:
                renderCarouselCover(component)
                
            case Components.carousel.rawValue:
                renderCarousel(component)
                
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func renderVStack(_ component: Element) -> some View {
        if let properties = component.properties {
            if let spacing = properties.spacing {
                VStack(spacing: spacing) {
                    if let elements = component.elements {
                        renderChildren(components: elements)
                    }
                }
            } else {
                VStack {
                    if let elements = component.elements {
                        renderChildren(components: elements)
                    }
                }
            }
        } else {
            VStack {
                if let elements = component.elements {
                    renderChildren(components: elements)
                }
            }
        }
    }

    @ViewBuilder
    private func renderScrollView(_ component: Element) -> some View {
        ScrollView {
            if let elements = component.elements {
                renderChildren(components: elements)
            }
        }
    }

    @ViewBuilder
    private func renderNavigationLink(_ component: Element) -> some View {
        if let properties = component.properties,
           let value = properties.value,
           let elements = component.elements {
            NavigationLink(value: value) {
                renderChildren(components: elements)
            }
        }
    }

    @ViewBuilder
    private func renderText(_ component: Element) -> some View {
        if let properties = component.properties,
           let value = properties.value {
            Text(value)
        }
    }

    @ViewBuilder
    private func renderDashboardText(_ component: Element) -> some View {
        if let properties = component.properties,
           let value = properties.value {
            DashboardText(value)
        }
    }

    @ViewBuilder
    private func renderSubtitle(_ component: Element) -> some View {
        if let properties = component.properties,
           let value = properties.value {
            Subtitle(value)
        }
    }

    @ViewBuilder
    private func renderImage(_ component: Element) -> some View {
        if let properties = component.properties,
           let url = properties.url {
            AsyncImage(url: url)
        }
    }

    @ViewBuilder
    private func renderCard(_ component: Element) -> some View {
        if let properties = component.properties,
           let elements = component.elements {
            Card(
                title: properties.title,
                color: Color.from(name: properties.color ?? ""),
                elements: elements
            )
        }
    }

    @ViewBuilder
    private func renderHStack(_ component: Element) -> some View {
        if let properties = component.properties {
            if let spacing = properties.spacing {
                HStack(spacing: spacing) {
                    if let elements = component.elements {
                        renderChildren(components: elements)
                    }
                }
            } else {
                HStack {
                    if let elements = component.elements {
                        renderChildren(components: elements)
                    }
                }
            }
        } else {
            HStack {
                if let elements = component.elements {
                    renderChildren(components: elements)
                }
            }
        }
    }

    @ViewBuilder
    private func renderCarouselCover(_ component: Element) -> some View {
        if let properties = component.properties {
            CarouselCover(properties: properties)
        }
    }

    @ViewBuilder
    private func renderCarousel(_ component: Element) -> some View {
        if let elements = component.elements {
            Carousel(elements: elements)
        }
    }
}
