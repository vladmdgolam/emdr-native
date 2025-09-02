# EMDR iOS App

A Metal-powered EMDR (Eye Movement Desensitization and Reprocessing) therapy app for iOS, macOS, and visionOS.

## Overview

This SwiftUI-based application provides smooth bilateral stimulation through a moving white dot, commonly used in EMDR therapy sessions. The app leverages Metal rendering for optimal performance and smooth animations across Apple platforms.

## Features

- **Smooth Metal Rendering**: Hardware-accelerated dot movement for consistent performance
- **Adjustable Speed**: Drag vertically to change dot speed (100-8000 points/second)
- **Pause/Resume**: Single tap to pause or resume the movement
- **Reset Function**: Triple tap to reset to default settings (2500 pt/s)
- **Cross-Platform**: Supports iPhone, iPad, Mac, and Apple Vision Pro
- **Clean Interface**: Minimal HUD that appears only when adjusting settings

## Controls

| Gesture | Action |
|---------|--------|
| **Single Tap** | Pause/Resume movement |
| **Triple Tap** | Reset to default speed (2500 pt/s) |
| **Vertical Drag** | Adjust speed (up = faster, down = slower) |

## Technical Details

### Architecture
- **SwiftUI** for the user interface
- **Metal** for high-performance rendering
- **Custom MetalView** for gesture handling and dot animation
- **MVVM pattern** with `@State` property wrappers

### Performance
- Default speed: 2500 points/second
- Speed range: 100-8000 points/second
- 60fps rendering with Metal
- Optimized for battery efficiency

## Requirements

- **iOS**: 26.0+
- **macOS**: 15.6+
- **visionOS**: 26.0+
- **Xcode**: 16.0+
- **Swift**: 5.0+

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd emdr
   ```

2. Open the project:
   ```bash
   open emdr.xcodeproj
   ```

3. Configure your development team and bundle identifier in the project settings

4. Build and run on your target device

## Project Structure

```
emdr/
├── emdr/
│   ├── emdrApp.swift          # App entry point
│   ├── ContentView.swift      # Main UI and gesture handling
│   ├── MetalView.swift        # Metal rendering view
│   └── MetalRenderer.swift    # Metal rendering logic
├── emdr.xcodeproj/           # Xcode project files
└── Assets.xcassets/          # App icons and assets
```

## Development

### Key Components

- **ContentView**: Main SwiftUI view handling state and gestures
- **MetalView**: UIViewRepresentable wrapper for Metal rendering
- **MetalRenderer**: Core Metal rendering engine for smooth animations

### Customization

The app can be easily customized by modifying:
- Default speed in `ContentView.swift`
- Dot size via `dotDiameter` property
- Color scheme in the Metal renderer
- Speed adjustment sensitivity

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple devices
5. Submit a pull request

## License

[Add your license here]

## Disclaimer

This app is designed as a tool to support EMDR therapy but should only be used under the guidance of a qualified mental health professional. It is not a replacement for professional therapy or medical treatment.

## Support

For issues or questions:
- Open an issue in this repository
- Contact: [Your contact information]

---

Built with ❤️ using SwiftUI and Metal