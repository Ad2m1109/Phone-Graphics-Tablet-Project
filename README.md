# Phone Graphics Tablet

Use your Android phone as a USB-connected mouse and graphics tablet for your PC.

## Features

-   Relative mouse movement.
-   Left-click (via double-tap).
-   Right-click (via two-finger tap).
-   Click-and-drag mode.

---

## How to Use (Setup Instructions)

### 1. PC Prerequisite: Install ADB

You need the Android Debug Bridge (`adb`) on your computer.

-   Download the "SDK Platform-Tools" for your operating system from the official Android developer website: [https://developer.android.com/tools/releases/platform-tools](https://developer.android.com/tools/releases/platform-tools)
-   Unzip the file. You will need to run commands from a terminal inside the unzipped `platform-tools` folder.

### 2. Phone Prerequisite: Enable USB Debugging

You need to enable "USB Debugging" on your Android phone.

-   Go to **Settings -> About phone**.
-   Tap on the **"Build number"** seven times until it says "You are now a developer!".
-   Go back to the main Settings menu and find the new **"Developer options"** menu.
-   Inside "Developer options", find and enable **"USB debugging"**.

### 3. Running the Application

1.  **Connect your phone** to your PC with a USB cable. A prompt might appear on your phone asking you to "Allow USB debugging". Check "Always allow" and tap **Allow**.

2.  **On your Phone**, start this application.

3.  In the phone app, go to **Settings** and turn **ON** the **"Start USB Server"** switch.

4.  **On your PC**, open a terminal and run the `adb forward` command to create the connection tunnel:
    ```bash
    adb forward tcp:38383 tcp:38383
    ```

5.  **On your PC**, open a second terminal, navigate to the `pc_client` directory within this project, and run the client:
    ```bash
    node index.js
    ```

The PC client terminal should now print `[Client] Connected to phone server.`, and you can control your PC's mouse from your phone.

---

## Project Components

-   **Flutter App:** The Android application that captures touch input.
-   **Node.js PC Client:** A lightweight script that runs on the PC, receives data from the phone, and controls the mouse.
