# SpatialEventGesture Bug on iOS 26.0 (23A5260n) Beta 

> **A minimal demo project** showcasing a regression in `SpatialEventGesture` on iOS 26.0 beta.

---

## 📱 Environment

- **Device:** iPhone
- **iOS Versions Tested:**
  - **18.5 (22F76)** — ✔️ Works as expected  
  - **26.0 (23A5260n) beta** — ❌ Buggy behavior  
- **Repo:** [SpatialEventGesture_Bug_iOS26BetaApp](https://github.com/…/SpatialEventGesture_Bug_iOS26BetaApp)

---

## 🚀 Reproduction Steps

1. Clone or download this project  
2. Open **SpatialEventGesture_Bug_iOS26BetaApp.xcodeproj** in Xcode 15.6  
3. Build & run on a **physical** iPhone (simulator does *not* reproduce)  
4. In the running app, place two fingers on the screen—both remain active  
5. **On iOS 18.5:**  
   - Add a third, fourth, and fifth finger **simultaneously** or **serially** → all touches continue to register  
   - Adding a **6th** finger cancels everything (as documented)  
6. **On iOS 26.0 beta:**  
   - Place **three** fingers on the screen simultaneously → **all touches are canceled** immediately  

---

## 🎯 Expected Behavior

1. **Up to five** simultaneous touches should remain active.  
2. Only when a **6th** finger appears—either all at once or one after another—should the system cancel the gesture and deliver a `.cancelled` phase.

---

## 🐞 Actual (Buggy) Behavior on iOS 26.0 Beta

- **Only two** simultaneous touches are allowed.  
- The moment a **3rd** finger touches, **all** active touches are cancelled.

---

## 🔍 Minimal Code Sample

```swift
HStack(spacing: 0) {
  let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
  ForEach(0..<colors.count, id: \.self) { i in
    Rectangle()
      .foregroundColor(colors[i])
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
.gesture(
  SpatialEventGesture()
    .onChanged { events in
      print("Active:", events.filter { $0.phase == .active }.map(\.location))
    }
    .onEnded { events in
      if events.contains(where: { $0.phase == .cancelled }) {
        print("⚠️ Gesture cancelled prematurely")
      }
    }
)
