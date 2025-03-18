// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../widgets/common/custom_button.dart';
// import 'custom_dialog.dart';

// class ScanModal extends StatefulWidget {
//   final Function(XFile) onImageSelected;
//   final VoidCallback? onClose;

//   const ScanModal({super.key, required this.onImageSelected, this.onClose});

//   static Future<void> show({
//     required BuildContext context,
//     required Function(XFile) onImageSelected,
//     VoidCallback? onClose,
//   }) {
//     return CustomDialog.show(
//       context: context,
//       title: 'Scan Eye',
//       content: ScanModal(onImageSelected: onImageSelected, onClose: onClose),
//     );
//   }

//   @override
//   State<ScanModal> createState() => _ScanModalState();
// }

// class _ScanModalState extends State<ScanModal> {
//   bool _isLoading = false;

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       setState(() => _isLoading = true);
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: source);

//       if (image != null) {
//         widget.onImageSelected(image);
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           'Choose an option to scan your eye:',
//           style: theme.textTheme.bodyLarge,
//         ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Expanded(
//               child: CustomButton(
//                 text: 'Take Photo',
//                 icon: Icons.camera_alt,
//                 onPressed:
//                     _isLoading ? () {} : () => _pickImage(ImageSource.camera),
//                 isLoading: _isLoading,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: CustomButton(
//                 text: 'Upload Photo',
//                 icon: Icons.upload_file,
//                 onPressed:
//                     _isLoading ? () {} : () => _pickImage(ImageSource.gallery),
//                 isLoading: _isLoading,
//                 isOutlined: true,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Please ensure good lighting and a clear view of your eye.',
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }
