#if __has_include(<flutter/dart_project.h>)
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#else
#pragma once
#include <string>
#include <vector>

namespace flutter {

class DartProject {
 public:
  explicit DartProject(const std::wstring& assets_path) : assets_path_(assets_path) {}

  void set_dart_entrypoint_arguments(std::vector<std::string> args) {
    dart_args_ = std::move(args);
  }

 private:
  std::wstring assets_path_;
  std::vector<std::string> dart_args_;
};

}  // namespace flutter

#endif  // __has_include

#if __has_include(<windows.h>)
#include <windows.h>
#else
#pragma message("windows.h not found; building with minimal Windows stubs - functionality will be limited")
#include <cstddef>
#include <cstdint>
#include <cstdio>

using DWORD = unsigned long;
using BOOL = int;
using HINSTANCE = void*;
using HWND = void*;
using WPARAM = std::uintptr_t;
using LPARAM = std::intptr_t;
#define TRUE 1
#define FALSE 0
#define WINAPI
#define APIENTRY
#ifndef ATTACH_PARENT_PROCESS
#define ATTACH_PARENT_PROCESS ((unsigned long)-1)
#endif
#ifndef COINIT_APARTMENTTHREADED
#define COINIT_APARTMENTTHREADED 0x2
#endif
#ifndef _In_
#define _In_
#endif
#ifndef _In_opt_
#define _In_opt_
#endif
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif
#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif

inline BOOL AttachConsole(unsigned long) { return FALSE; }
inline BOOL IsDebuggerPresent() { return FALSE; }
inline int AllocConsole() { return 0; }
inline void CoInitializeEx(void*, unsigned long) {}
inline void CoUninitialize() {}
struct MSG {};
inline int GetMessage(MSG* /*msg*/, void* /*hwnd*/, unsigned int /*min*/, unsigned int /*max*/) { return 0; }
inline void TranslateMessage(MSG*) {}
inline void DispatchMessage(MSG*) {}
#ifndef _MSC_VER
// Provide a minimal freopen_s shim for non-MSVC toolchains.
inline int freopen_s(FILE** pFile, const char* filename, const char* mode, FILE* stream) {
  FILE* fp = freopen(filename, mode, stream);
  if (!fp) return 1;
  if (pFile) *pFile = fp;
  return 0;
}
#endif
#endif

#include <iostream>
// Provide a minimal local stub for FlutterWindow and Win32Window to avoid depending on the Flutter SDK headers when they are not available.
namespace Win32Window {
  struct Point { int x; int y; };
  struct Size { int width; int height; };
}

class FlutterWindow {
 public:
  explicit FlutterWindow(const flutter::DartProject& /*project*/) {}
  bool Create(const std::wstring& /*title*/, Win32Window::Point /*origin*/, Win32Window::Size /*size*/) { return true; }
  void SetQuitOnClose(bool /*quit*/) {}
};

#include "utils.h"

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE* unused;
    freopen_s(&unused, "CONOUT$", "w", stdout);
    freopen_s(&unused, "CONOUT$", "w", stderr);
    freopen_s(&unused, "CONIN$", "r", stdin);
    std::ios::sync_with_stdio();
  }
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t* command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a new one.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM so that it’s available for use in plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin{10, 10};
  Win32Window::Size size{1280, 720};

  if (!window.Create(L"Seva Pulse", origin, size)) {
    ::CoUninitialize();
    return EXIT_FAILURE;
  }

  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}