//
//  ShareGameStorySheet.swift
//  GameNet
//
//  Pré-visualização e escolha do modelo antes de mandar pro Instagram.
//

import SwiftUI

#if os(iOS)
struct ShareGameStorySheet: View {

    // MARK: Lifecycle

    init(content: GameStoryContent) {
        _viewModel = StateObject(wrappedValue: ShareGameStoryViewModel(content: content))
    }

    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                preview

                templatePicker

                actions
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Compartilhar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            await viewModel.loadCover()
        }
        .sheet(item: $viewModel.fallbackShare) { item in
            StoryShareActivityView(image: item.image)
        }
        .alert(
            "Ops",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented { viewModel.errorMessage = nil }
                }
            ),
            presenting: viewModel.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    // MARK: Private

    @StateObject private var viewModel: ShareGameStoryViewModel
    @Environment(\.dismiss) private var dismiss

    private var preview: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / GameStoryCanvasView.size.width,
                geometry.size.height / GameStoryCanvasView.size.height
            )

            TimelineView(.periodic(from: Date(), by: 1)) { context in
                GameStoryCanvasView(
                    content: viewModel.content,
                    template: viewModel.template,
                    cover: viewModel.cover,
                    accent: viewModel.accent,
                    elapsedText: viewModel.content.elapsedText(at: context.date)
                )
                .scaleEffect(scale, anchor: .center)
                .frame(
                    width: GameStoryCanvasView.size.width * scale,
                    height: GameStoryCanvasView.size.height * scale
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                if viewModel.isLoadingCover {
                    ProgressView()
                        .tint(.white)
                }
            }
            .animation(.gameNetSmooth, value: viewModel.template)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var templatePicker: some View {
        HStack(spacing: 10) {
            ForEach(InstagramStoryTemplate.allCases) { template in
                Button {
                    withAnimation(.gameNetSmooth) {
                        viewModel.template = template
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: template.icon)
                            .font(.system(size: 18, weight: .semibold))

                        Text(template.title)
                            .font(.dashboardGameSubtitle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                viewModel.template == template
                                    ? Color.main.opacity(0.85)
                                    : Color.white.opacity(0.1)
                            )
                    )
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("story-template-\(template.rawValue)")
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                Task { await viewModel.shareOnInstagram() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera.circle.fill")
                    Text(viewModel.isInstagramAvailable ? "Compartilhar no Instagram" : "Compartilhar story")
                }
                .font(.listCardTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .gameNetGlassProminentButtonStyle(tint: .main)
            .disabled(viewModel.isSharing)

            Button {
                viewModel.shareElsewhere()
            } label: {
                Text("Outras opções")
                    .font(.dashboardGameSubtitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.75))
            .disabled(viewModel.isSharing)
        }
    }
}
#endif
