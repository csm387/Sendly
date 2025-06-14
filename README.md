# Sendly

A modern, feature-rich API testing tool built with Flutter. Sendly provides a beautiful and intuitive interface for testing APIs, managing requests, and organizing your API collections.

## Features

- 🎨 Beautiful Material Design 3 UI with dark mode support
- 🔄 Multiple HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
- 📦 Request body and headers management
- 🔑 Authentication support (Basic Auth, Bearer Token)
- 🌍 Environment variables and configuration
- 📚 Request history and templates
- 📁 Project and collection management
- ⚡ Real-time response preview
- 📋 Copy response to clipboard
- 🎯 Request timeout configuration
- 🔍 Search functionality for projects, curls, and history

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/sendly.git
   ```

2. Navigate to the project directory:
   ```bash
   cd sendly
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app/
│   ├── app.dart             # Main app widget
│   └── theme.dart           # Theme configuration
├── models/
│   ├── project.dart         # Project model
│   ├── request.dart         # Request model
│   └── environment.dart     # Environment model
├── screens/
│   ├── request_screen.dart  # Request tab
│   ├── response_screen.dart # Response tab
│   └── collections_screen.dart # Collections tab
├── widgets/
│   ├── request/
│   │   ├── header.dart      # Request header widget
│   │   ├── body.dart        # Request body widget
│   │   └── params.dart      # Parameters widget
│   ├── response/
│   │   ├── info.dart        # Response info widget
│   │   └── preview.dart     # Response preview widget
│   └── collections/
│       ├── project_list.dart # Project list widget
│       └── history_list.dart # History list widget
└── services/
    ├── storage.dart         # Local storage service
    └── http_service.dart    # HTTP request service
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the beautiful design system
- All contributors who have helped shape this project

---

> Made with 🖤 by csm