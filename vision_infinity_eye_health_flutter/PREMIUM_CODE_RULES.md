# Premium Code Rules for Vision Infinity Eye Health App

## 1. Architecture & Structure

### 1.1 Clean Architecture
- **Strict Separation of Concerns**: Maintain clear boundaries between UI, business logic, and data layers
- **Dependency Rule**: Inner layers must not depend on outer layers
- **Feature-First Organization**: Group code by feature rather than by type

### 1.2 State Management
- **Riverpod as Primary Solution**: Use Riverpod for state management with proper provider organization
- **Immutable State**: Ensure all state objects are immutable
- **Atomic Updates**: State changes should be atomic and predictable
- **Provider Naming**: Follow consistent naming patterns (e.g., `entityProvider`, `entityNotifierProvider`)

### 1.3 Folder Structure
- **Feature-Based Modules**: Organize code by features/domains
- **Consistent Naming**: Use consistent naming conventions across the project
- **Separation of Widgets**: Split complex widgets into smaller, reusable components

## 2. UI/UX Excellence

### 2.1 Responsive Design
- **Device Agnostic**: All UI must adapt perfectly to any screen size
- **Orientation Support**: Support both portrait and landscape orientations
- **Accessibility Scaling**: Support text scaling and accessibility features

### 2.2 Animation & Transitions
- **Purposeful Animations**: Every animation must serve a purpose (feedback, guidance, delight)
- **Performance Optimized**: Use `AnimationController` with `TickerProviderStateMixin` for complex animations
- **Consistent Timing**: Maintain consistent animation durations throughout the app
- **Staggered Animations**: Use staggered animations for complex UI elements

### 2.3 Visual Consistency
- **Theme-Based Styling**: All styling must come from the app's theme
- **No Magic Numbers**: Extract all dimensions, durations, and colors to named constants
- **Design System**: Follow a consistent design system for spacing, typography, and colors

## 3. Code Quality

### 3.1 Naming Conventions
- **Descriptive Names**: Use clear, descriptive names for all identifiers
- **Consistent Casing**: camelCase for variables/methods, PascalCase for classes/types
- **Private Members**: Prefix private members with underscore

### 3.2 Function Design
- **Single Responsibility**: Each function should do exactly one thing
- **Parameter Limits**: Maximum 3-4 parameters; use named parameters for more
- **Pure Functions**: Prefer pure functions without side effects
- **Early Returns**: Use early returns to reduce nesting

### 3.3 Comments & Documentation
- **Self-Documenting Code**: Write code that explains itself
- **API Documentation**: Document all public APIs with dartdoc comments
- **Complex Logic**: Add comments only for complex algorithms or business rules
- **TODO Management**: Mark incomplete features with TODO comments including ticket references

## 4. Performance Optimization

### 4.1 Widget Efficiency
- **const Constructors**: Use const constructors wherever possible
- **Stateless When Possible**: Prefer StatelessWidget over StatefulWidget
- **Minimal Rebuilds**: Use selective rebuilds with Riverpod's select
- **Widget Keys**: Use proper keys for dynamic lists

### 4.2 Resource Management
- **Dispose Resources**: Always dispose controllers, streams, and other resources
- **Lazy Loading**: Implement lazy loading for lists and heavy resources
- **Image Optimization**: Use appropriate image formats and resolutions
- **Memory Profiling**: Regularly profile memory usage

### 4.3 Rendering Optimization
- **Repaint Boundaries**: Use RepaintBoundary for complex, independent UI sections
- **Cached Widgets**: Cache expensive widget builds
- **Avoid Expensive Layouts**: Minimize nested Columns/Rows and expensive layout widgets

## 5. Advanced UI Techniques

### 5.1 Custom Painting
- **Optimized Canvas Operations**: Minimize canvas operations
- **Cached Painting**: Cache complex painting operations
- **Hardware Acceleration**: Ensure UI uses hardware acceleration

### 5.2 Gesture Handling
- **Intuitive Gestures**: Use natural, intuitive gestures
- **Feedback**: Provide visual and haptic feedback for all interactions
- **Gesture Disambiguation**: Handle gesture conflicts properly

### 5.3 Advanced Animations
- **Physics-Based Animations**: Use physics-based animations for natural feel
- **Custom Curves**: Define custom curves for unique animation effects
- **Hero Transitions**: Use Hero widgets for smooth transitions between screens

## 6. Error Handling & Resilience

### 6.1 Comprehensive Error Handling
- **User-Friendly Messages**: Convert technical errors to user-friendly messages
- **Graceful Degradation**: Provide fallback UI when features fail
- **Error Boundaries**: Implement error boundaries to prevent app crashes

### 6.2 Logging & Monitoring
- **Structured Logging**: Use structured logging with severity levels
- **Performance Metrics**: Log performance metrics for critical operations
- **User Journey Tracking**: Track user journeys for UX improvement

## 7. Testing Excellence

### 7.1 Test Coverage
- **Comprehensive Testing**: Aim for >90% test coverage
- **Test Pyramid**: Balance unit, widget, and integration tests
- **Golden Tests**: Use golden tests for UI verification

### 7.2 Test Quality
- **Arrange-Act-Assert**: Follow AAA pattern in tests
- **Test Independence**: Each test must be independent
- **Mock External Dependencies**: Always mock external dependencies

## 8. Code Review Standards

### 8.1 Review Checklist
- **Performance Impact**: Assess performance impact of changes
- **Accessibility**: Verify accessibility compliance
- **Error Handling**: Confirm proper error handling
- **Edge Cases**: Consider all edge cases

### 8.2 Continuous Improvement
- **Refactoring**: Continuously refactor code for improvement
- **Knowledge Sharing**: Document complex solutions for team learning
- **Pattern Recognition**: Identify recurring patterns for abstraction

## 9. Eye Health App Specific Guidelines

### 9.1 Scanning Experience
- **Smooth Animations**: Implement fluid, reassuring animations during scanning
- **Clear Instructions**: Provide clear, step-by-step guidance
- **Progress Indication**: Always show clear progress indicators
- **Error Recovery**: Allow easy recovery from failed scans

### 9.2 Medical UI Best Practices
- **Clarity Over Aesthetics**: Prioritize clarity in medical information display
- **Consistent Terminology**: Use consistent medical terminology
- **Color Accessibility**: Ensure color schemes work for color-blind users
- **Critical Information Hierarchy**: Establish clear visual hierarchy for critical information

### 9.3 Data Visualization
- **Accurate Representations**: Ensure medical data visualizations are accurate
- **Intuitive Scales**: Use intuitive scales and units
- **Comparative Views**: Enable easy comparison of results over time
- **Contextual Information**: Provide context for interpreting results

## 10. Continuous Excellence

### 10.1 Stay Updated
- **Flutter Updates**: Stay current with Flutter framework updates
- **Design Trends**: Follow modern design trends while maintaining consistency
- **Performance Techniques**: Continuously research and apply new performance techniques

### 10.2 User-Centered Development
- **User Feedback Loop**: Incorporate user feedback in development
- **Usability Testing**: Conduct regular usability testing
- **Accessibility First**: Consider accessibility from the beginning

---

These premium code rules are designed to ensure the Vision Infinity Eye Health App maintains the highest standards of code quality, performance, and user experience. Following these guidelines will result in a product that is not only technically excellent but also provides exceptional value to users.