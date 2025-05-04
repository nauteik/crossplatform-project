import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/image_helper.dart';

class ProductGallery extends StatelessWidget {
  final List<String> images;
  final ValueNotifier<int> selectedImageIndex;

  const ProductGallery({
    super.key,
    required this.images,
    required this.selectedImageIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu không có ảnh, hiển thị placeholder
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.white,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 50,
            color: Colors.grey.shade300,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main image
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.white,
            child: ValueListenableBuilder<int>(
              valueListenable: selectedImageIndex,
              builder: (context, selectedIndex, _) {
                final index = selectedIndex.clamp(0, images.length - 1);
                return Image.network(
                  ImageHelper.getImage(images[index]),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.grey.shade300,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Thumbnail images
          if (images.length > 1) ...[
            Container(
              height: 80,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ValueListenableBuilder<int>(
                    valueListenable: selectedImageIndex,
                    builder: (context, selectedIndex, _) {
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          selectedImageIndex.value = index;
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              '${ApiConstants.baseApiUrl}/api/images/${images[index]}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 24,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
} 