import SwiftUI

nonisolated enum AppThemeMode: String, CaseIterable, Sendable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

enum AuriseTheme {
    static let accent = Color(red: 0.30, green: 0.70, blue: 0.95)
    static let accentSoft = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let accentGlow = Color(red: 0.25, green: 0.65, blue: 0.92)
    static let premiumGold = Color(red: 0.40, green: 0.75, blue: 0.98)

    static let primaryText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    })

    static let secondaryText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.6)
            : UIColor(red: 0.35, green: 0.35, blue: 0.42, alpha: 1.0)
    })

    static let tertiaryText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.35)
            : UIColor(red: 0.55, green: 0.55, blue: 0.60, alpha: 1.0)
    })

    static let cardFill = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.06)
            : UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
    })

    static let cardBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor(red: 0.88, green: 0.88, blue: 0.91, alpha: 1.0)
    })

    static let cardSelectedFill = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.70, blue: 0.95, alpha: 0.12)
            : UIColor(red: 0.30, green: 0.70, blue: 0.95, alpha: 0.08)
    })

    static let cardSelectedBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.70, blue: 0.95, alpha: 0.4)
            : UIColor(red: 0.30, green: 0.70, blue: 0.95, alpha: 0.5)
    })

    static let pageBg = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
    })

    static let surfaceDark = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0)
            : UIColor(red: 0.94, green: 0.94, blue: 0.97, alpha: 1.0)
    })

    static let subtleFill = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.06)
            : UIColor.black.withAlphaComponent(0.04)
    })

    static let subtleBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)
    })

    static let divider = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.06)
            : UIColor.black.withAlphaComponent(0.06)
    })

    static let radioUnselected = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.15)
            : UIColor.black.withAlphaComponent(0.15)
    })

    static let disabledFill = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)
    })

    static let buttonOverlay = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.15)
            : UIColor.white.withAlphaComponent(0.25)
    })

    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.25, green: 0.65, blue: 0.92),
            Color(red: 0.35, green: 0.75, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = RadialGradient(
        colors: [
            Color(red: 0.25, green: 0.65, blue: 0.92).opacity(0.35),
            Color(red: 0.20, green: 0.55, blue: 0.85).opacity(0.12),
            Color.clear
        ],
        center: .top,
        startRadius: 50,
        endRadius: 400
    )

    static let premiumShimmer = LinearGradient(
        colors: [
            Color(red: 0.30, green: 0.70, blue: 0.95),
            Color(red: 0.50, green: 0.82, blue: 0.98),
            Color(red: 0.30, green: 0.70, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let meshGradientDark = MeshGradient(
        width: 3, height: 3,
        points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ],
        colors: [
            Color(red: 0.02, green: 0.04, blue: 0.06),
            Color(red: 0.05, green: 0.12, blue: 0.18),
            Color(red: 0.02, green: 0.04, blue: 0.06),
            Color(red: 0.04, green: 0.10, blue: 0.16),
            Color(red: 0.08, green: 0.18, blue: 0.28),
            Color(red: 0.04, green: 0.08, blue: 0.14),
            Color(red: 0.02, green: 0.04, blue: 0.06),
            Color(red: 0.03, green: 0.06, blue: 0.10),
            Color(red: 0.02, green: 0.04, blue: 0.06)
        ]
    )

    static let meshGradientLight = MeshGradient(
        width: 3, height: 3,
        points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ],
        colors: [
            Color(red: 0.94, green: 0.97, blue: 1.0),
            Color(red: 0.88, green: 0.95, blue: 1.0),
            Color(red: 0.94, green: 0.97, blue: 1.0),
            Color(red: 0.90, green: 0.96, blue: 1.0),
            Color(red: 0.84, green: 0.93, blue: 1.0),
            Color(red: 0.92, green: 0.96, blue: 1.0),
            Color(red: 0.94, green: 0.97, blue: 1.0),
            Color(red: 0.91, green: 0.96, blue: 1.0),
            Color(red: 0.94, green: 0.97, blue: 1.0)
        ]
    )
}

struct AdaptiveMeshBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                AuriseTheme.meshGradientDark
            } else {
                AuriseTheme.meshGradientLight
            }
        }
        .ignoresSafeArea()
    }
}
