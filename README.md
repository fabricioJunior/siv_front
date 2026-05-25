# siv_front

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### macOS Setup 🍎

1.  **Install CUPS dependencies**:

    ```bash
    brew install cups
    ```

2.  **Ensure CUPS is running**:

    ```bash
    sudo launchctl start org.cups.cupsd
    ```

3.  **Update `macos/Podfile`** to include the `printing_ffi` plugin. Use the following `Podfile`:

    ```ruby
    platform :osx, '10.15'

    # Disable CocoaPods analytics for faster builds
    ENV['COCOAPODS_DISABLE_STATS'] = 'true'

    project 'Runner', {
      'Debug' => :debug,
      'Profile' => :release,
      'Release' => :release,
    }

    def flutter_root
      generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'ephemeral', 'Flutter-Generated.xcconfig'), __FILE__)
      unless File.exist?(generated_xcode_build_settings_path)
        raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure \"flutter pub get\" is executed first"
      end

      File.foreach(generated_xcode_build_settings_path) do |line|
        matches = line.match(/FLUTTER_ROOT\=(.*)/)
        return matches[1].strip if matches
      end
      raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Flutter-Generated.xcconfig, then run \"flutter pub get\""
    end

    require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

    flutter_macos_podfile_setup

    target 'Runner' do
      use_frameworks!
      pod 'printing_ffi', :path => '../' # Path to the printing_ffi plugin
      flutter_install_all_macos_pods File.dirname(File.realpath(__FILE__))
    end

    post_install do |installer|
      installer.pods_project.targets.each do |target|
        flutter_additional_macos_build_settings(target)
      end
    end
    ```

4.  **Run `pod install`** in the `macos` directory:

    ```bash
    cd macos
    pod install
    ```

5.  **Verify `printing_ffi.framework`**: Ensure it's built and included in `macos/Flutter/ephemeral/.app`.

### Windows Setup 🪟

The plugin uses the native `winspool` API for printing. For PDF printing, it bundles the PDFium library.

#### PDF Printing and Compatibility

If you are using `printing_ffi` for PDF printing on Windows, you may need to initialize the PDFium library.

*   **If you are also using another PDF plugin (like `pdfrx`)**: You do **not** need to do anything. The other plugin will handle PDFium's initialization, and `printing_ffi` will use the existing instance.

*   **If `printing_ffi` is your ONLY PDFium-based plugin**: You **must** call `initPdfium()` once when your app starts. This ensures the library is initialized correctly on the main thread.
