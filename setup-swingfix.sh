#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "Run this script from inside the SwingFix Git repository."
  exit 1
fi

cd "$REPO_ROOT"

command -v gh >/dev/null 2>&1 || { echo "GitHub CLI is not installed."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run: gh auth login"; exit 1; }

PROJECT_DIR="SwingFix/SwingFix"

mkdir -p \
  "$PROJECT_DIR/App" \
  "$PROJECT_DIR/Core/AI" \
  "$PROJECT_DIR/Core/Camera" \
  "$PROJECT_DIR/Core/Persistence" \
  "$PROJECT_DIR/Core/Video" \
  "$PROJECT_DIR/Core/Vision" \
  "$PROJECT_DIR/Features/Home" \
  "$PROJECT_DIR/Features/Capture" \
  "$PROJECT_DIR/Features/Library" \
  "$PROJECT_DIR/Features/Analysis" \
  "$PROJECT_DIR/Features/Compare" \
  "$PROJECT_DIR/Features/Coaching" \
  "$PROJECT_DIR/Features/Settings" \
  "$PROJECT_DIR/DesignSystem/Components" \
  "$PROJECT_DIR/DesignSystem/Colors" \
  "$PROJECT_DIR/DesignSystem/Typography" \
  "$PROJECT_DIR/Models" \
  "$PROJECT_DIR/Services" \
  "$PROJECT_DIR/Resources" \
  "$PROJECT_DIR/SupportingFiles" \
  "docs/Decisions" \
  ".github/ISSUE_TEMPLATE" \
  ".github/workflows"

find "$PROJECT_DIR/Core" "$PROJECT_DIR/Features" "$PROJECT_DIR/DesignSystem" \
  "$PROJECT_DIR/Models" "$PROJECT_DIR/Services" "$PROJECT_DIR/Resources" \
  "$PROJECT_DIR/SupportingFiles" -type d -empty -exec touch {}/.gitkeep \;

cat > docs/ProductVision.md <<'EOF'
# SwingFix Product Vision

SwingFix is a private, AI-assisted iPhone golf swing coach. It helps a golfer record or import swing videos, identify the most important movement issue, understand why it matters, and receive a focused drill.

## Product principles

1. Give one or two high-priority corrections.
2. Keep swing videos private by default.
3. Track improvement over time.
4. Avoid claiming launch-monitor precision from ordinary phone video.
5. Design for fast use at the range.
EOF

cat > docs/Roadmap.md <<'EOF'
# Roadmap

## MVP v0.1
- Home screen
- Import video
- Camera capture
- Video playback
- Local swing storage
- Swing history
- Placeholder analysis
- Initial Apple Vision pose detection

## Beta v0.5
- Swing phase detection
- Body-position scoring
- Side-by-side comparison
- Personalized drills
- Progress trends

## App Store v1.0
- Production-ready analysis
- Onboarding and camera setup guidance
- Accessibility and performance hardening
- Privacy disclosures
- App Store release workflow
EOF

cat > docs/Architecture.md <<'EOF'
# Architecture

SwingFix uses a feature-oriented SwiftUI architecture.

- `App`: app entry point and root navigation
- `Features`: user-facing feature modules
- `Core`: camera, video, persistence, Vision, and AI capabilities
- `DesignSystem`: reusable UI components and tokens
- `Models`: shared domain models
- `Services`: coordination services and integrations

Initial stack: SwiftUI, SwiftData, AVFoundation, PhotosUI, and Apple Vision.
EOF

cat > docs/CodingStandards.md <<'EOF'
# Coding Standards

- Prefer small, focused Swift types.
- Keep views declarative.
- Move business logic into services or view models.
- Avoid force unwraps.
- Add tests for non-trivial analysis and persistence logic.
- Keep commits small and tied to one issue.
- Use feature branches and pull requests.
EOF

cat > docs/UIUX.md <<'EOF'
# UI and UX

- Use large touch targets.
- Prioritize one primary action per screen.
- Support light and dark mode.
- Keep coaching language concise.
- Clearly distinguish measured results from estimates.
- Use overlays only when they improve understanding.
EOF

cat > docs/AI.md <<'EOF'
# AI and Computer Vision

Initial analysis will focus on observable body mechanics: head movement, spine-angle change, hip rotation and depth, shoulder rotation, knee flex, balance, and tempo.

Do not claim exact club path, face angle, ball speed, or carry distance without appropriate sensor data. Label low-confidence measurements and prefer deterministic measurements before generative coaching.
EOF

cat > docs/Decisions/0001-native-ios.md <<'EOF'
# ADR 0001: Native iOS Application

## Status
Accepted

## Decision
Build SwingFix as a native SwiftUI iPhone application.

## Rationale
Native iOS provides direct access to camera capture, PhotosUI, AVFoundation, Apple Vision, SwiftData, and on-device processing.
EOF

cat > docs/Decisions/0002-local-first.md <<'EOF'
# ADR 0002: Local-First Storage

## Status
Accepted

## Decision
Store swing videos, metadata, and initial analysis locally by default.

## Rationale
Accounts are unnecessary for the MVP, and local-first storage reduces cost and privacy risk.
EOF

cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
## Summary
Describe what changed and why.

## Related issue
Closes #

## Testing
- [ ] App builds successfully
- [ ] Tested in iPhone simulator
- [ ] Tested on a physical iPhone when camera behavior changed
- [ ] No new warnings introduced

## Screenshots
Add screenshots for visual changes.
EOF

cat > .github/ISSUE_TEMPLATE/feature.yml <<'EOF'
name: Feature
description: Propose or implement a SwingFix feature
title: "[Feature] "
labels: ["feature"]
body:
  - type: textarea
    id: goal
    attributes:
      label: Goal
      description: What user outcome should this feature produce?
    validations:
      required: true
  - type: textarea
    id: requirements
    attributes:
      label: Requirements
      description: List the acceptance criteria.
    validations:
      required: true
EOF

cat > .github/ISSUE_TEMPLATE/bug.yml <<'EOF'
name: Bug
description: Report a SwingFix defect
title: "[Bug] "
labels: ["bug"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to reproduce
    validations:
      required: true
EOF

cat > .github/workflows/ios-build.yml <<'EOF'
name: iOS Build

on:
  pull_request:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: |
          xcodebuild \
            -project SwingFix/SwingFix.xcodeproj \
            -scheme SwingFix \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            CODE_SIGNING_ALLOWED=NO \
            build
EOF

create_label() {
  gh label create "$1" --color "$2" --description "$3" --force >/dev/null
}

create_label feature 1D76DB "New product functionality"
create_label bug D73A4A "Something is not working"
create_label enhancement A2EEEF "Improvement to existing behavior"
create_label documentation 0075CA "Documentation updates"
create_label ios 000000 "Native iOS work"
create_label vision 7057FF "Apple Vision and pose analysis"
create_label ai 8B5CF6 "AI coaching and inference"
create_label design E99695 "UI and UX work"
create_label tech-debt FBCA04 "Technical debt or refactoring"
create_label "good first issue" 7057FF "Approachable starter work"
create_label epic 5319E7 "Large body of related work"

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
EXISTING_MILESTONE="$(gh api "repos/$REPO/milestones?state=all" --jq '.[] | select(.title=="MVP v0.1") | .number' | head -n1)"
if [[ -z "$EXISTING_MILESTONE" ]]; then
  gh api --method POST "repos/$REPO/milestones"     -f title='MVP v0.1'     -f description='Record or import swings, play videos, save sessions, and deliver initial analysis.' >/dev/null
fi

create_issue() {
  local title="$1"
  local body="$2"
  local labels="$3"
  local existing
  existing="$(gh issue list --state all --search "\"$title\" in:title" --json title --jq ".[] | select(.title==\"$title\") | .title" | head -n1)"
  if [[ -z "$existing" ]]; then
    gh issue create --title "$title" --body "$body" --label "$labels" --milestone "MVP v0.1" >/dev/null
  fi
}

create_issue "EPIC: Build SwingFix MVP" "Deliver the first usable SwingFix release." "epic,feature,ios"
create_issue "Build Home Screen" "Create the landing page with Record Swing, Import Video, and Recent Swings." "feature,ios,design"
create_issue "Import Swing Video" "Select a golf swing video from Photos and continue to review." "feature,ios"
create_issue "Record Swing" "Record a swing using the rear camera with permissions and clear states." "feature,ios"
create_issue "Build Video Playback" "Add play, pause, scrubbing, and frame-by-frame review." "feature,ios"
create_issue "Create Local Swing Storage" "Persist swing metadata and app-managed video references." "feature,ios"
create_issue "Build Swing History" "Show saved swing sessions with date, club, angle, and status." "feature,ios,design"
create_issue "Add Apple Vision Pose Detection" "Extract body joints from video frames with confidence values." "feature,ios,vision"
create_issue "Detect Swing Phases" "Identify address, backswing, top, downswing, impact, and finish." "feature,vision,ai"
create_issue "Build Analysis Screen" "Show the main swing issue, measurements, confidence, and drill." "feature,design,ai"

echo
echo "SwingFix setup complete."
echo "Next:"
echo "  git status"
echo '  git add .'
echo '  git commit -m "Set up project architecture and GitHub workflow"'
echo '  git push'
