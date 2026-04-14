# NetSentinel - iOS Network Security Auditor

NetSentinel is a security-focused iOS application designed to audit your local network for connected devices and identify potential security risks through mDNS discovery and targeted port scanning.

## Features

- **Network Discovery:** Uses Apple's `Network` framework (`NWBrowser`) to discover devices via Bonjour/mDNS.
- **Port Auditing:** Performs TCP port probing on discovered devices to check for common insecure services.
- **Security Analysis:** Automatically evaluates discovered ports and services against a set of security rules to flag high and medium risk vulnerabilities.
- **Actionable Recommendations:** Provides specific advice on how to harden your network (e.g., disabling legacy protocols like Telnet or FTP).

## Technical Architecture

### Core Components

1.  **NetworkScanner (`Services/NetworkScanner.swift`):**
    - Leverages `NWBrowser` to listen for Bonjour service advertisements on the local network.
    - Specifically browses for common services like HTTP, SSH, and SMB to identify active hosts.
2.  **PortScanner (`Services/PortScanner.swift`):**
    - Uses `NWConnection` to attempt TCP connections to a curated list of high-risk ports.
    - Confirmed ports monitored: 21 (FTP), 22 (SSH), 23 (Telnet), 80 (HTTP), 445 (SMB), 3306 (MySQL), 3389 (RDP).
3.  **SecurityAnalyzer (`Services/SecurityAnalyzer.swift`):**
    - A rules engine that transforms raw port data into readable security reports.
    - Categorizes issues by severity (Low, Medium, High) based on protocol insecurity and common exploit vectors.
4.  **SwiftUI Dashboard:**
    - Provides a real-time overview of network health and a detailed drill-down into each device's security posture.

## Project Structure

```text
NetSentinel/
├── Models/             # Data structures (NetworkDevice, SecurityIssue)
├── Services/           # Network discovery and scanning logic
├── Views/              # SwiftUI interface components
├── Resources/          # Info.plist and other assets
└── NetSentinelApp.swift # App entry point
```

## Setup & Build Instructions

1.  **Prerequisites:** macOS with Xcode 14.0 or later.
2.  **Open Project:**
    - Open Xcode and select "Create a new Xcode project".
    - Choose "iOS" -> "App".
    - Name the project `NetSentinel` and ensure the interface is set to "SwiftUI".
3.  **Import Files:**
    - Drag the contents of the `NetSentinel` directory into your Xcode project navigator.
    - When prompted, ensure "Copy items if needed" is checked and the target `NetSentinel` is selected.
4.  **Configure Permissions:**
    - NetSentinel requires local network access. The `Info.plist` includes the mandatory `NSLocalNetworkUsageDescription` and `NSBonjourServices` keys.
5.  **Run:**
    - Select a physical iOS device or simulator.
    - Press `Cmd + R` to build and run.
    - *Note: Discovery and port scanning work best on a physical device connected to a real local Wi-Fi network.*

## Security Notice

NetSentinel is intended for personal use and network auditing of devices you own or have permission to scan. Unauthorized port scanning can be flagged by network intrusion detection systems.
