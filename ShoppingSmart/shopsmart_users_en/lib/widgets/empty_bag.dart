import 'package:flutter/material.dart';

class EmptyBagWidget extends StatefulWidget {
  const EmptyBagWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  final String imagePath, title, subtitle, buttonText;

  @override
  State<EmptyBagWidget> createState() => _EmptyBagWidgetState();
}

class _EmptyBagWidgetState extends State<EmptyBagWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),

                  // Animated Image Container
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.35,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Floating stars animation
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Main cart image
                                  Container(
                                    width: size.width * 0.4,
                                    height: size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        widget.imagePath,
                                        width: size.width * 0.25,
                                        height: size.width * 0.25,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  // Floating stars
                                  ...List.generate(6, (index) {
                                    return Positioned(
                                      left:
                                          [
                                            20,
                                            60,
                                            100,
                                            140,
                                            30,
                                            110,
                                          ][index].toDouble(),
                                      top:
                                          [
                                            30,
                                            80,
                                            20,
                                            70,
                                            120,
                                            140,
                                          ][index].toDouble(),
                                      child: TweenAnimationBuilder(
                                        duration: Duration(
                                          milliseconds: 1500 + (index * 200),
                                        ),
                                        tween: Tween<double>(begin: 0, end: 1),
                                        builder: (
                                          context,
                                          double value,
                                          child,
                                        ) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Container(
                                              width:
                                                  [
                                                    12,
                                                    8,
                                                    10,
                                                    6,
                                                    14,
                                                    8,
                                                  ][index].toDouble(),
                                              height:
                                                  [
                                                    12,
                                                    8,
                                                    10,
                                                    6,
                                                    14,
                                                    8,
                                                  ][index].toDouble(),
                                              decoration: BoxDecoration(
                                                color:
                                                    [
                                                      Colors.amber,
                                                      Colors.orange,
                                                      Colors.pink,
                                                      Colors.purple,
                                                      Colors.blue,
                                                      Colors.green,
                                                    ][index],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Cute emoji
                              Text("🛒✨", style: TextStyle(fontSize: 28)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Ôi! Giỏ hàng trống",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Enhanced button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: size.width * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to home/shop
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            widget.buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Suggested actions
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "💡 Quick Actions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickAction(
                                context,
                                "🔥",
                                "Best Sellers",
                                () {
                                  // Navigate to search screen with "All" to show best sellers
                                  Navigator.pushNamed(
                                    context,
                                    '/SearchScreen',
                                    arguments: "All",
                                  );
                                },
                              ),
                              _buildQuickAction(context, "💝", "Offers", () {
                                // Navigate to offers screen
                                Navigator.pushNamed(context, "/OffersScreen");
                              }),
                              _buildQuickAction(context, "❤️", "Wishlist", () {
                                // Navigate to wishlist
                                Navigator.pushNamed(context, "/WishlistScreen");
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String emoji,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
