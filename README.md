# Phone Graphics Tablet (PGT) - Mobile to PC Drawing Interface

A cross-platform application that transforms smartphones into graphic tablets, allowing users to draw on their phone screen and see the results in real-time on their PC. The system enables cost-effective digital drawing by leveraging existing mobile devices.

## Problem Statement

Professional graphic tablets are expensive ($100-$2000+), creating barriers for:

- Digital art students
- Hobbyist artists
- Beginner digital creators
- Professionals needing secondary tablets

## Solution

Utilize smartphone touchscreens as input devices, transmitting drawing data to PC software that mimics professional tablet functionality.

## High-Level Architecture

[Mobile Device] ←→ [Network: WiFi/Bluetooth] ←→ [PC Application] ←→ [Digital Art Software]

## Component Diagram

┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Mobile App                 │───▶│           Communication   │───▶│   PC Server                           │
│  (Flutter)      │    │   Layer (Socket) │    │   (Python)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Touch Input                        │     │ Data Serialization│                      │ Drawing Render  │
│ Processing      │                         │   (JSON/Protobuf) │                     │ & Display       │
└─────────────────┘    └──────────────────┘    └─────────────────┘

## Technical Specifications

### Mobile Application (Flutter)

- **Platform**: Android 8.0+ (API 26+), iOS 12+
- **Framework**: Flutter 3.0+
- **Dependencies**:
    - `flutter_bluetooth_serial` for Bluetooth
    - `socket_io_client` for WiFi communication
    - `shared_preferences` for local storage
    - `permission_handler` for device permissions

### PC Server Application (Python)

- **Platform**: Windows 10/11, macOS 10.15+, Linux Ubuntu 18.04+
- **Python Version**: 3.8+
- **Dependencies**:
    - `pygame` for rendering
    - `pyautogui` for system control
    - `websockets` for network communication
    - `pynput` for input simulation
    - `opencv-python` for advanced features

## Data Protocol Specification

- **Primary**: WebSocket over WiFi
- **Fallback**: RFCOMM over Bluetooth
- **Port**: 8888 (configurable)
- **Data Format**: JSON