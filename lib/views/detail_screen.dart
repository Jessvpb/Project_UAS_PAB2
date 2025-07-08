import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akiflash/view_models/auth_view_model.dart';
import 'package:akiflash/models/aki_product.dart';
import 'package:akiflash/providers/theme_provider.dart';
import 'package:geocoding/geocoding.dart';

class DetailScreen extends StatefulWidget {
  final AkiProduct product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
        _fabAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Product Image
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).cardColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FutureBuilder<bool>(
                  future: authViewModel.isFavorite(widget.product.id),
                  builder: (context, favoriteSnapshot) {
                    bool isFavorite = favoriteSnapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? Colors.red
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () async {
                        await authViewModel.toggleFavorite(widget.product.id);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'product-${widget.product.id}',
                        child: Container(
                          margin: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.battery_unknown_rounded,
                                      color: Colors.grey[400],
                                      size: 80,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.product.discount != null)
                      Positioned(
                        top: 100,
                        right: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            '${widget.product.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Title and Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          widget.product.type,
                                          style: const TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp ${widget.product.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                    if (widget.product.discount != null)
                                      Text(
                                        'Save ${widget.product.discount}%',
                                        style: TextStyle(
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Quantity Selector
                            _buildQuantitySelector(),

                            const SizedBox(height: 32),

                            // Description
                            _buildSection(
                              'Description',
                              Icons.description_outlined,
                              widget.product.description,
                            ),

                            const SizedBox(height: 24),

                            // Specifications (if available)
                            _buildSection(
                              'Specifications',
                              Icons.settings_outlined,
                              'Type: ${widget.product.type}\nBrand: Premium Quality\nWarranty: 1 Year',
                            ),

                            const SizedBox(height: 32),

                            // Reviews Section
                            _buildReviewsSection(authViewModel),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: _showFab
                ? FloatingActionButton.extended(
                    onPressed: () => _addToCart(authViewModel),
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    icon: const Icon(Icons.shopping_cart_rounded),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addToCart(authViewModel),
                  icon: const Icon(Icons.shopping_cart_rounded),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Row(
            children: [
              _buildQuantityButton(
                Icons.remove_rounded,
                () => setState(
                  () => _quantity = _quantity > 1 ? _quantity - 1 : 1,
                ),
                _quantity > 1,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              _buildQuantityButton(
                Icons.add_rounded,
                () => setState(() => _quantity++),
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed,
    bool enabled,
  ) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1976D2) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.import_contacts,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _getAddressFromCoordinates(
    dynamic latitude,
    dynamic longitude,
  ) async {
    try {
      // Convert to double if needed
      double? lat;
      double? lng;

      if (latitude is String) {
        lat = double.tryParse(latitude);
      } else if (latitude is num) {
        lat = latitude.toDouble();
      }

      if (longitude is String) {
        lng = double.tryParse(longitude);
      } else if (longitude is num) {
        lng = longitude.toDouble();
      }

      // Log the converted coordinates for debugging
      print('Converted coordinates - lat: $lat, lng: $lng');

      // Check for null or invalid coordinates
      if (lat == null || lng == null) {
        print('Error: Could not convert coordinates to double');
        return 'Invalid coordinates format';
      }

      // Validate coordinate ranges
      if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
        print('Error: Invalid coordinate range - lat: $lat, lng: $lng');
        return 'Invalid coordinate range';
      }

      // Add timeout to prevent hanging
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 15));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        print('Geocoding successful, parsing placemark...');

        // Build address string with null-safe operations
        List<String> addressParts = [];

        // Safely extract each field with null checks
        String? street = placemark.street;
        String? subLocality = placemark.subLocality;
        String? locality = placemark.locality;
        String? subAdministrativeArea = placemark.subAdministrativeArea;
        String? administrativeArea = placemark.administrativeArea;
        String? country = placemark.country;
        String? postalCode = placemark.postalCode;

        // Add non-null and non-empty parts
        if (street != null && street.isNotEmpty) {
          addressParts.add(street);
        }
        if (subLocality != null && subLocality.isNotEmpty) {
          addressParts.add(subLocality);
        }
        if (locality != null && locality.isNotEmpty) {
          addressParts.add(locality);
        }
        if (subAdministrativeArea != null && subAdministrativeArea.isNotEmpty) {
          addressParts.add(subAdministrativeArea);
        }
        if (administrativeArea != null && administrativeArea.isNotEmpty) {
          addressParts.add(administrativeArea);
        }
        if (country != null && country.isNotEmpty) {
          addressParts.add(country);
        }

        // Log the successful parsing
        print('Address parts found: $addressParts');

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        } else {
          // If no address parts found, try to use name or other fields
          String? name = placemark.name;
          if (name != null && name.isNotEmpty) {
            return name;
          }
          return 'Address details not available';
        }
      }

      print('Error: No placemarks returned');
      return 'Address not found';
    } catch (e) {
      print('Geocoding error details: $e');
      print('Error type: ${e.runtimeType}');
      return 'Failed to retrieve address';
    }
  }

  Widget _buildReviewsSection(AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: authViewModel.getReviews(widget.product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1976D2)),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to review this product',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            final reviews = snapshot.data!;
            return Column(
              children: reviews.map((review) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rating: ${review['rating'] ?? 'N/A'}/5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review['comment'] ?? 'No comment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Use the conservative geocoding method
                            _buildAddressWidget(review),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<String> _getAddressFromCoordinatesConservative(
    dynamic latitude,
    dynamic longitude,
  ) async {
    try {
      // Convert to double if needed
      double? lat;
      double? lng;

      if (latitude is String) {
        lat = double.tryParse(latitude);
      } else if (latitude is num) {
        lat = latitude.toDouble();
      }

      if (longitude is String) {
        lng = double.tryParse(longitude);
      } else if (longitude is num) {
        lng = longitude.toDouble();
      }

      if (lat == null || lng == null) {
        return 'Invalid coordinates';
      }

      if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
        return 'Invalid coordinate range';
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isEmpty) {
        return 'No address found';
      }

      final placemark = placemarks.first;

      // Very conservative approach - only use non-null fields
      List<String> parts = [];

      try {
        if (placemark.locality != null &&
            placemark.locality!.trim().isNotEmpty) {
          parts.add(placemark.locality!.trim());
        }
      } catch (e) {
        print('Error accessing locality: $e');
      }

      try {
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.trim().isNotEmpty) {
          parts.add(placemark.administrativeArea!.trim());
        }
      } catch (e) {
        print('Error accessing administrativeArea: $e');
      }

      try {
        if (placemark.country != null && placemark.country!.trim().isNotEmpty) {
          parts.add(placemark.country!.trim());
        }
      } catch (e) {
        print('Error accessing country: $e');
      }

      if (parts.isNotEmpty) {
        return parts.join(', ');
      }

      // Last resort - just return coordinates
      return 'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    } catch (e) {
      print('Conservative geocoding error: $e');
      return 'Address unavailable';
    }
  }

  Widget _buildAddressWidget(Map<String, dynamic> review) {
    // Check if coordinates exist and are valid
    final lat = review['latitude'];
    final lng = review['longitude'];

    if (lat == null || lng == null) {
      return Text(
        'Address not available',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return FutureBuilder<String>(
      future: _getAddressFromCoordinatesConservative(lat, lng),
      builder: (context, addressSnapshot) {
        if (addressSnapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Loading address...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        }

        if (addressSnapshot.hasError) {
          print('Address widget error: ${addressSnapshot.error}');
          return Text(
            'Address error',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[400],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        return Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                addressSnapshot.data ?? 'Address not available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(AuthViewModel authViewModel) async {
    await authViewModel.addToCart(widget.product.id, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('Added $_quantity item(s) to cart'),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
