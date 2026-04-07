# PokemonGuideWidget - Setup Guide

## 1. Add the Widget Extension Target in Xcode

1. Open `PokemonGuide.xcodeproj` in Xcode.
2. Go to **File > New > Target...**
3. Select **Widget Extension** under the iOS tab.
4. Configure:
   - **Product Name**: `PokemonGuideWidget`
   - **Team**: your signing team
   - **Include Configuration App Intent**: leave **unchecked** (we use `StaticConfiguration`)
   - **Include Live Activity**: leave unchecked
5. Click **Finish**. Xcode creates a new group and scheme.
6. **Delete** the auto-generated Swift files in the new `PokemonGuideWidget/` group.
7. **Add** the `PokemonGuideWidget.swift` file from this directory into the target (drag it into the Xcode group, or File > Add Files, making sure the `PokemonGuideWidget` target is checked).

## 2. Configure the App Group

Both the main app and the widget need to share data through a common App Group container.

### Create the App Group

1. Select the **PokemonGuide** project in the navigator.
2. Select the **PokemonGuide** (main app) target.
3. Go to **Signing & Capabilities**.
4. Click **+ Capability** > **App Groups**.
5. Add the group: `group.com.brunocerecetto.PokemonGuide`
6. Repeat for the **PokemonGuideWidget** target:
   - Select the widget target > Signing & Capabilities > + Capability > App Groups.
   - Add the same group: `group.com.brunocerecetto.PokemonGuide`

### Verify in Apple Developer Portal

If Xcode doesn't auto-register the App Group:

1. Go to [developer.apple.com/account](https://developer.apple.com/account).
2. Under **Certificates, Identifiers & Profiles** > **Identifiers** > **App Groups**, make sure `group.com.brunocerecetto.PokemonGuide` exists.
3. Under both app identifiers (main app and widget extension), enable the **App Groups** capability and select this group.

## 3. Update ProgressManager to Write to the Shared Container

The main app currently writes to `UserDefaults.standard`. The widget runs in a separate process and cannot read `UserDefaults.standard` from the main app. You need to write progress data to the shared App Group container.

### Changes to `ProgressManager.swift`

Replace the `defaults` property:

```swift
// Before
private let defaults = UserDefaults.standard

// After
private let defaults: UserDefaults

// In init(), before any other code:
self.defaults = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
```

Also update the static helper methods that reference `UserDefaults.standard`:

```swift
// In load(forKey:) — replace UserDefaults.standard:
private static func load(forKey key: String) -> Set<String> {
    let defaults = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
    let array = defaults.stringArray(forKey: key) ?? []
    return Set(array)
}

// In loadPokedex(forKey:) — same change:
private static func loadPokedex(forKey key: String) -> [Int: PokemonStatus] {
    let defaults = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
    guard let dict = defaults.dictionary(forKey: key) as? [String: Int] else {
        return [:]
    }
    // ... rest unchanged
}

// In migrateIfNeeded — same change:
private static func migrateIfNeeded(from oldKey: String, to newKey: String) {
    let shared = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
    let standard = UserDefaults.standard

    // Migrate from standard to shared if needed
    guard shared.object(forKey: newKey) == nil else { return }
    if let oldValue = shared.object(forKey: oldKey) {
        shared.set(oldValue, forKey: newKey)
        shared.removeObject(forKey: oldKey)
    } else if let oldValue = standard.object(forKey: oldKey) {
        // Also migrate from standard UserDefaults to shared container
        shared.set(oldValue, forKey: newKey)
        standard.removeObject(forKey: oldKey)
    }
}
```

### Changes to `GameConfig.swift`

Same pattern — replace `UserDefaults.standard` with the shared suite:

```swift
// Before
private let defaults = UserDefaults.standard

// After
private let defaults: UserDefaults

// In init():
let defaults = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
self.defaults = defaults
// ... rest of init uses `defaults` already
```

Also update the static references in init:

```swift
init() {
    let defaults = UserDefaults(suiteName: "group.com.brunocerecetto.PokemonGuide") ?? .standard
    self.defaults = defaults

    let savedVersion = defaults.string(forKey: Self.versionKey)
        .flatMap(GameVersion.init(rawValue:)) ?? .fireRed
    let savedStarter = defaults.string(forKey: Self.starterKey)
        .flatMap(Starter.init(rawValue:)) ?? .squirtle

    _version = Published(initialValue: savedVersion)
    _starter = Published(initialValue: savedStarter)
}
```

### Notify the Widget When Data Changes

After each save in `ProgressManager`, tell WidgetKit to refresh. Add this import and helper:

```swift
import WidgetKit

// Add at the end of each save method, or in a central place:
private func notifyWidget() {
    WidgetCenter.shared.reloadAllTimelines()
}
```

Call `notifyWidget()` in the `didSet` observers. A simple approach — add it to the save helper:

```swift
private func save(_ set: Set<String>, forKey key: String) {
    defaults.set(Array(set), forKey: key)
    notifyWidget()
}
```

### Write Next Route Steps for the Medium Widget

The medium widget shows the next 3 uncompleted route steps by description. The widget can't access `GameData` (it's in the main app target), so the main app must cache these strings in the shared container.

Add this method to `ProgressManager` and call it whenever route progress changes:

```swift
func syncNextRouteStepsForWidget() {
    let allSteps = GameData.routeSections.flatMap(\.steps)
    let nextSteps = allSteps
        .filter { !completedRouteSteps.contains($0.id) }
        .prefix(3)
        .map(\.text)

    defaults.set(Array(nextSteps), forKey: "\(prefix)_nextRouteSteps")
}
```

Call this in the `completedRouteSteps` `didSet`:

```swift
@Published var completedRouteSteps: Set<String> {
    didSet {
        save(completedRouteSteps, forKey: routeKey)
        syncNextRouteStepsForWidget()
    }
}
```

Also call it once in `init()` and `switchConfig()` to populate the initial value.

## 4. Deployment Target

Make sure the widget extension's deployment target matches the main app's. Check both targets under **General > Minimum Deployments**.

## 5. Build & Test

1. Select the **PokemonGuideWidget** scheme in Xcode.
2. Build (Cmd+B) to verify compilation.
3. To preview the widget, use the `#Preview` macros at the bottom of `PokemonGuideWidget.swift`.
4. To test on simulator:
   - Run the main app first (to populate shared UserDefaults).
   - Add the widget to the home screen (long press > Edit Home Screen > + button > search "PokemonGuide").
5. Verify data flows by toggling progress in the app and checking that the widget updates.

## Summary of All Required Changes

| File | Change |
|------|--------|
| `ProgressManager.swift` | Switch `UserDefaults.standard` to shared suite; add `notifyWidget()`; add `syncNextRouteStepsForWidget()` |
| `GameConfig.swift` | Switch `UserDefaults.standard` to shared suite |
| Xcode project | Add Widget Extension target; add App Group to both targets |
| `PokemonGuideWidget.swift` | New file (provided) |
