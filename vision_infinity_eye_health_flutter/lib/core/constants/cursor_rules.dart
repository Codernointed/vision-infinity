// Cursor Rules for Code Organization and Navigation

/// Reference Project Location
/// Reference project: C:\Users\Student\Downloads\vision-infinity-eye-health
library;


/// Clean Architecture Rules
class CursorRules {
  /// 1. Screen Component Rules
  static const screenRules = {
    'prohibited_direct_usage': [
      'Colors', // Use theme.colorScheme instead
      'TextStyle', // Use theme.textTheme instead
      'ElevatedButton', // Use CustomButton instead
      'Text', // Use CustomText instead
      'Container', // Use CustomContainer or Card instead
      'TextField', // Use CustomInput instead
      'AppBar', // Use CustomAppBar instead
    ],
    'required_practices': [
      'Use super.key in all widget constructors',
      'All UI components must come from /widgets directory',
      'All colors must come from theme.colorScheme',
      'All text styles must come from theme.textTheme',
      'All spacing must use predefined constants',
      'All icons must use predefined constants',
    ],
  };

  /// 2. Architecture Layer Rules
  static const architectureLayers = {
    'presentation': {
      'location': '/lib/screens',
      'responsibilities': [
        'Screen layout composition',
        'Widget arrangement',
        'Navigation logic',
        'State management integration',
      ],
      'restrictions': [
        'No direct API calls',
        'No business logic',
        'No direct state manipulation',
        'No custom styling',
      ],
    },
    'widgets': {
      'location': '/lib/widgets',
      'categories': [
        '/common', // Shared components like buttons, inputs
        '/ui', // Complex UI components
        '/layouts', // Layout components
        '/feedback', // Alerts, toasts, dialogs
      ],
    },
    'core': {
      'location': '/lib/core',
      'contents': [
        '/theme', // App theming
        '/constants', // App constants
        '/utils', // Utility functions
        '/providers', // State providers
      ],
    },
    'services': {
      'location': '/lib/services',
      'responsibilities': [
        'API communication',
        'Local storage',
        'Authentication',
        'Device features',
      ],
    },
    'models': {
      'location': '/lib/models',
      'requirements': [
        'Data classes',
        'JSON serialization',
        'Type definitions',
        'Immutable structures',
      ],
    },
  };

  /// 3. Component Creation Rules
  static const componentRules = {
    'naming': {'prefix': 'Custom', 'suffix': 'Widget/Screen/Service/Provider'},
    'structure': [
      'Constructor with super.key',
      'Required parameters first',
      'Optional parameters last',
      'Named parameters for 3+ params',
    ],
    'styling': [
      'Use ThemeData from context',
      'No hard-coded colors',
      'No hard-coded dimensions',
      'No hard-coded text styles',
    ],
  };

  /// 4. File Structure Order
  static const fileStructureOrder = [
    'imports', // External package imports first, then local imports
    'constants', // Constants and enums
    'providers', // State providers (if using Riverpod)
    'classes', // Main classes
    'extensions', // Extension methods
    'helpers', // Helper functions
  ];

  /// 5. Class Member Order
  static const classMemberOrder = [
    'static_variables', // Static variables
    'instance_variables', // Instance variables
    'constructors', // Constructors (with super.key)
    'static_methods', // Static methods
    'lifecycle_methods', // Lifecycle methods (initState, dispose, etc.)
    'override_methods', // Overridden methods
    'public_methods', // Public methods
    'private_methods', // Private methods
    'build_methods', // Build methods (for widgets)
  ];

  /// 6. Import Order
  static const importOrder = [
    'dart:', // Dart SDK imports
    'package:flutter/', // Flutter imports
    'package:', // External package imports
    '../core/', // Core imports
    '../widgets/', // Widget imports
    '../services/', // Service imports
    '../models/', // Model imports
    './', // Local imports
  ];

  /// 7. Theme Usage Rules
  static const themeRules = {
    'colors': 'Always use theme.colorScheme',
    'text_styles': 'Always use theme.textTheme',
    'spacing': 'Use predefined spacing constants',
    'radius': 'Use predefined radius constants',
    'shadows': 'Use predefined shadow styles',
  };

  /// 8. Code Organization
  static const codeOrganization = {
    'max_file_length': 300, // Recommended maximum lines per file
    'max_method_length': 50, // Recommended maximum lines per method
    'max_parameters': 4, // Recommended maximum parameters per method
    'prefer_small_widgets': true, // Break large widgets into smaller components
  };

  /// 9. State Management
  static const stateManagementRules = [
    'Use Riverpod for state management',
    'Providers at top of file',
    'State variables grouped together',
    'State updates in dedicated methods',
    'Clear state disposal in dispose()',
  ];

  /// 10. Error Handling
  static const errorHandlingRules = [
    'Use custom error handlers',
    'Implement proper error reporting',
    'Handle edge cases explicitly',
    'Use custom error widgets',
  ];

  /// 11. Performance Rules
  static const performanceRules = [
    'Use const constructors',
    'Minimize rebuilds',
    'Lazy load when possible',
    'Cache network images',
  ];

  /// 12. Documentation Rules
  static const documentationRules = [
    'Document all public APIs',
    'Include usage examples',
    'Document parameters',
    'Document state management',
  ];
}
