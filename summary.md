# System Architecture Summary

## Overview

This project transforms an Android phone into a USB-connected graphics tablet and mouse for a PC. The system consists of two main components:

1.  **A mobile application** built with Flutter that runs on the Android phone.
2.  **A PC client** built with Node.js that runs on the user's computer (Windows, macOS, or Linux).

The phone app captures touch gestures and sends them to the PC client, which then translates them into native mouse movements and clicks.

---

## How It Works (Connectivity)

The connection is established over a USB cable using a TCP socket forwarded by the Android Debug Bridge (adb).

1.  **Phone as Server:** The Flutter application opens a `ServerSocket` and listens for incoming connections on its local loopback address (`127.0.0.1`) at port `38383`.

2.  **PC Port Forwarding:** The `adb forward tcp:38383 tcp:38383` command creates a communication tunnel over the USB cable. It maps the PC's port `38383` to the phone's port `38383`.

3.  **PC as Client:** The Node.js PC client acts as a TCP client. It attempts to connect to port `38383` on its own `localhost`. The `adb` tunnel intercepts this connection and forwards it to the waiting `ServerSocket` on the phone, thus establishing a direct link between the two applications.

---

## Data Protocol

Communication is achieved by sending simple JSON objects from the phone to the PC. Each JSON string is terminated by a newline character (`\n`) to ensure messages are framed and processed correctly.

-   **Movement:** `{"dx":10,"dy":-5,"mode":"move"}`
-   **Dragging:** `{"dx":10,"dy":-5,"mode":"draw"}`
-   **Right Click:** `{"dx":0,"dy":0,"mode":"right_click"}`
-   **Double Click:** `{"dx":0,"dy":0,"mode":"double_click"}`

---

## Technologies Used

### Mobile Application (Android)

-   **Framework:** Flutter
-   **Language:** Dart
-   **Key Libraries:**
    -   `dart:io`: Used for creating the TCP `ServerSocket` to listen for the PC client.

### PC Client (Cross-Platform)

-   **Runtime:** Node.js
-   **Language:** JavaScript
-   **Key Libraries:**
    -   `net`: The built-in Node.js module used to create the TCP client.
    -   `robotjs`: A powerful library used to control the PC's mouse cursor for movement and clicks.

### Connectivity

-   **Android Debug Bridge (`adb`):** The command-line tool used to create the vital port-forwarding tunnel over the USB connection.
