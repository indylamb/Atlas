import SwiftUI

// The floating bottom-left action button and top map controls

struct BottomToolbar: View {
    var onSearch: () -> Void
    var onFilter: () -> Void
    var onLocate: () -> Void
    var activeFilterCount: Int

    @State private var showMenu = false

    var body: some View {
        HStack(alignment: .bottom) {
            // Left: main action button
            VStack(spacing: 10) {
                // Filter button (shows above)
                if showMenu {
                    Button {
                        showMenu = false
                        onFilter()
                    } label: {
                        MenuOption(icon: "slider.horizontal.3",
                                   label: "Filter",
                                   badge: activeFilterCount > 0 ? "\(activeFilterCount)" : nil)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    Button {
                        showMenu = false
                        onSearch()
                    } label: {
                        MenuOption(icon: "magnifyingglass", label: "Search")
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Main FAB
                Button {
                    HapticsHelper.medium()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        showMenu.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.Atlas.blue)
                            .frame(width: 54, height: 54)
                            .shadow(color: Color.Atlas.blue.opacity(0.4), radius: 12, x: 0, y: 6)

                        Image(systemName: showMenu ? "xmark" : "plus")
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(showMenu ? 45 : 0))
                            .animation(.spring(response: 0.3), value: showMenu)
                    }
                }
            }

            Spacer()

            // Right: compass/locate
            VStack(spacing: 10) {
                if activeFilterCount > 0 {
                    // Active filter indicator
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(activeFilterCount) filter\(activeFilterCount == 1 ? "" : "s")")
                            .font(AtlasFont.caption(11))
                    }
                    .foregroundStyle(Color.Atlas.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.Atlas.blueLight)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                }

                AtlasIconButton(symbol: "location.fill", size: 15, action: onLocate)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct MenuOption: View {
    let icon: String
    let label: String
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(AtlasFont.label(13))
                .foregroundStyle(Color.Atlas.textPrimary)

            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Color.Atlas.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.Atlas.background)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.09), radius: 8, x: 0, y: 3)

                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Circle().fill(Color.Atlas.blue))
                        .offset(x: 2, y: -2)
                }
            }
        }
    }
}
