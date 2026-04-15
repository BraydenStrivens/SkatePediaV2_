//
//  TrickListSpinnerView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

/// A custom spinning wheel view used to randomly select a trick from the user's trick list.
///
/// Displays tricks in a vertically scrolling “spinner” format with physics-based motion.
/// Users can spin the wheel via drag gesture or instantly randomize selection.
///
/// Supports filtering via `SpinnerFilter`, which updates the underlying trick set.
///
/// Also integrates with custom spinner presets via `TrickSpinnerPresetsView`.
///
/// - Important:
///   The spinner internally maintains a shuffled ordering of tricks and simulates
///   inertial motion using velocity + deceleration rather than relying on native scrolling.
///
/// - Parameters:
///   - viewModel: View model responsible for providing filtered trick data and spinner state.
///   - trickSpinnerPresetsVM: View model managing saved spinner presets.
struct TrickListSpinnerView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: TrickListSpinnerViewModel
    let trickSpinnerPresetsVM: TrickSpinnerPresetsViewModel
    
    @GestureState private var dragOffset: CGFloat = 0
    /// Internal shuffled order of tricks used for spinning.
    @State private var ordered: [Trick] = []
    /// Current fractional scroll position of the spinner.
    @State private var position: CGFloat = 0
    @State private var isSpinning: Bool = false
    
    private let rowHeight: CGFloat = 48
    private let visibleCount = 7
    
    init(
        viewModel: TrickListSpinnerViewModel,
        trickSpinnerPresetsVM: TrickSpinnerPresetsViewModel
    ) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.trickSpinnerPresetsVM = trickSpinnerPresetsVM
    }
    
    /// The filtered list of tricks used as the spinner source.
    var tricks: [Trick] {
        viewModel.trickList
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                spinner

                /// Displays total number of available tricks in current filter.
                Text("\(ordered.count) Tricks")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding()
            }

            /// Preset and filter selector for spinner configuration.
            TrickSpinnerPresetsView(
                selectedFilter: $viewModel.filter,
                viewModel: trickSpinnerPresetsVM
            )
        }
        .padding(.horizontal, 12)
        .customNavHeader(title: "Spinner")
        .onAppear {
            resetOrder()
        }
        /// Updates spinner when filter changes.
        .onChange(of: viewModel.filter) { _, newValue in
            withAnimation(.smooth) {
                viewModel.setFilter(newValue)
                resetOrder()
            }
        }
        /// Toolbar action for instant random selection.
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    instantRandom()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.callout)
                }
                .disabled(ordered.isEmpty)
            }
        }
    }
    
    /// Main spinner wheel UI.
    ///
    /// Displays a vertically centered selection window with surrounding
    /// trick rows that scale and fade based on distance from center.
    var spinner: some View {
        ZStack {
            if ordered.isEmpty {
                ContentUnavailableView {
                    Text("No Tricks")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("There are no tricks available that match the current filter.")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.button, lineWidth: 2)
                    .frame(height: rowHeight)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(-visibleRange()...visibleRange(), id: \.self) { index in
                        row(offsetIndex: index)
                            .frame(height: rowHeight)
                    }
                }
                .offset(y: scrollOffset())
            }
        }
        .frame(height: rowHeight * CGFloat(visibleCount))
        .clipped()
        .gesture(spinGesture)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset)
    }
    
    private func resetOrder() {
        ordered = tricks.shuffled()
        position = 0
    }
    
    /// Number of rows shown above and below center.
    private func visibleRange() -> Int {
        visibleCount / 2
    }
    
    /// Computes the current centered index in the spinner.
    private func currentIndex() -> Int {
        guard !ordered.isEmpty else { return 0 }
        let index = Int(round(position))
        return mod(index, ordered.count)
    }
    
    /// Safe modulo for circular indexing.
    private func mod(_ a: Int, _ n: Int) -> Int {
        (a % n + n) % n
    }
    
    /// Calculates vertical offset for spinner motion.
    private func scrollOffset() -> CGFloat {
        let fractional = position - round(position)
        return -fractional * rowHeight + dragOffset
    }
    
    /// Builds a single spinner row with scaling and opacity effects.
    ///
    /// - Parameter offsetIndex: Distance from the center row.
    private func row(offsetIndex: Int) -> some View {
        guard !ordered.isEmpty else { return AnyView(EmptyView()) }
        
        let center = currentIndex()
        let index = mod(center + offsetIndex, ordered.count)
        
        let distance = abs(offsetIndex)
        
        let scale = max(0.6, 1 - CGFloat(distance) * 0.15)
        let opacity = max(0.25, 1 - Double(distance) * 0.2)
        
        return AnyView(
            Text(ordered[index]
                .displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true)
            )
            .font(distance == 0 ? .title2.weight(.bold) : .body)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        )
    }
    
    /// Drag gesture used to control spinner motion.
    private var spinGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                guard !ordered.isEmpty else { return }
                guard !isSpinning else { return }
                
                let velocity = value.velocity.height
                let drag = value.translation.height
                
                let impulse = -(drag + velocity * 0.2) / rowHeight
                
                startSpin(initialVelocity: impulse)
            }
    }
    
    /// Starts physics-based spinning animation.
    ///
    /// - Parameter initialVelocity: Initial spin velocity derived from gesture.
    private func startSpin(initialVelocity: CGFloat) {
        guard !tricks.isEmpty else { return }
        
        isSpinning = true
        ordered = tricks.shuffled()
        
        var velocity = initialVelocity
        
        velocity = min(max(velocity, -4), 4)
        
        let deceleration: CGFloat = 0.92
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            position += velocity
            velocity *= deceleration
            
            if abs(velocity) < 0.02 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    position = round(position)
                }
                
                position = CGFloat(mod(Int(position), ordered.count))
                
                isSpinning = false
                
                timer.invalidate()
            }
        }
    }
    
    /// Instantly selects a random trick without animation.
    private func instantRandom() {
        guard !tricks.isEmpty else { return }
        
        ordered = tricks.shuffled()
        
        withAnimation(.easeOut(duration: 0.25)) {
            position = CGFloat(Int.random(in: 0..<ordered.count))
        }
    }
}
