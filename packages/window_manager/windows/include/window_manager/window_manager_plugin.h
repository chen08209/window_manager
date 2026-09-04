#ifndef FLUTTER_PLUGIN_WINDOW_MANAGER_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_MANAGER_PLUGIN_H_

#include <windows.h>

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void WindowManagerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

// Finds the top-level window of another running instance of this executable,
// or nullptr. Safe to call before the engine exists; never returns a window
// of the calling process.
FLUTTER_PLUGIN_EXPORT HWND WindowManagerFindRunningWindow();

// Asks the plugin inside |window| to raise it, which it reports to Dart as
// the "activate" event. Works against an elevated instance too.
FLUTTER_PLUGIN_EXPORT void WindowManagerActivateWindow(HWND window);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_WINDOW_MANAGER_PLUGIN_H_
