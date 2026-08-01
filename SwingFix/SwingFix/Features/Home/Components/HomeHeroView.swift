import SwiftUI

struct HomeHeroView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.golf")
                .font(.system(size: 58))
                .foregroundStyle(AppColors.accent)

            Text("Your swing. One clear fix.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Record or import a swing and get focused feedback without the golf-jargon avalanche.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 14)
    }
}
