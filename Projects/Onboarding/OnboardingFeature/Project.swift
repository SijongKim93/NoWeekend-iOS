import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    name: "OnboardingFeature",
    targets: [
        .framework(
            name: "OnboardingFeature",
            bundleId: BundleID.Onboarding.feature,
            sources: ["Sources/**"],
            dependencies: [
                .Onboarding.domain,
                .Onboarding.data,
                .Core.coordinator,
                .Core.diContainer,
                .Shared.designSystem,
                .Shared.utils
            ],
            settings: .frameworkSettings
        )
    ]
)
