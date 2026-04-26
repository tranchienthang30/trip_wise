import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCcIAGSMxG1SRQD2tqHKeWeZH89c0RP3iuUuZzPKWmEKvvsU6WqjOm_s6saa_E5bzLmqtCn9SYiOweZn6-R_q5vyU3-HxfELpqh2Jo_rY2kDDWyJNCEG2ml0kU5uIVp8fTAa_6BOLkYzZXNGggTtji5agKeLI2E3nY4alD_ta7RH12AyVNUxsdNO0g8fe_nYKkmI81EAB_s1rrT4OKlcW6WIP1oAKEOJdtAEh1Jlir9sHfrqE4o9qbREdAw5_6KgrWLE9rDVrhqvhuY';

  static const String _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDz6pmBJWMNUYRoVnqgcflySIr095siDlcLFd2cX7ZxiN_2AMvOUH9i6KzhoerlXxj08Ejt_OrKieaCY_8YG_mwcrRAHFb0HuUVHYYOavPBuxcc5ykUUuObt1DZLKA4WJ_jKFLMfpMohgDhoJ958ctWVYw5AIHkEHYLwbj22HhyPRxBaD1b3DGZEGSEgi-bmYJHMbZoivxmVz6gG71okmM-lN7nTWYeZ1igkRB5Byh3D__KLL08oTls69i0HydGnJabt35dqonHJj5A';

  static const List<String> _categoryLabels = [
    'Food',
    'Sightseeing',
    'Transport',
    'Outdoors',
  ];

  static final List<_ActivityCardData> _smallTopRow = [
    const _ActivityCardData(
      title: 'Emerald Valley Hike',
      description: 'A moderate 3km trail through lush ferns and pines.',
      rating: '4.8',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCz-p9VFi6yn4ZGVlqYTkm1XVmstp7GiX4qa1J5LkK0yz3PiDNxLFGO5kj6IAGUMjGDMifyaPYaXfGnO0Q6IHiEHOY6GFqEDTIHqYOHF0ugbDr1JvAhfajM7ILQtUgXlrAnoXvEye8PD1cKDxrKZNAiH-acadIA8e9koPSaKQN9Hnqc_7_4RbRY4tBcjMMiIEiDuj1edMg2c22IjLvL0Y8VPB--N_0SRde6Q2Hi3e7dNHfzRmtOLA7TzSAt5XILgvmIEcIzs2k7xqWs',
    ),
    const _ActivityCardData(
      title: 'City Night Tour',
      description: 'Explore the vibrant lights and secret hidden bars.',
      rating: '4.7',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB-4vUg7B66IXiYGyBD2GNxL_8FDQPAvf68qWoM7rS19rtk31-bmws0ftf_5Bd6889vmCI_jyJ2M2xHIhw4sFHH4x942a0dtEMEPPng1AWuv6mwiIP3wVzxPFLiCTQUtcD_wTCbVfT53FZvNQChd1zKGJoF5Bvfg1FQgKzmSqjGayb0lHUR1JyvR0WgB15rDkSJEw_0ewNp3fohT88ItyiygPv_iC2mR-HcER74Q0Q2srFYW6MI9e9Qy4A0AIT6wSpHiP2xHsB8zZtF',
    ),
  ];

  static final _ActivityCardData _wideCard = const _ActivityCardData(
    title: 'Luxury Coastal Coach',
    description:
        'Stress-free transit with reclining seats and panoramic windows. Includes refreshments.',
    rating: '4.5',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBx9Jx6Y7rc52RQojM15AfVJal0XdZMORwlu0I7V99n1BLyUQH0Qnh_wmGUUadU64zaR8H4NpiL9UWCZBnistxpkF7h0oMc0swxsak2ru-HXVitsRPiF2UtdKU9T-X_61hZs7P0D41A7ett6rucinrVWp4ph6wby0vfosHXz3Xk-K8n1FJ7KY3rpNul4T11pNKHWKm_H17ps8vGBv8FkJaf7ttzaZ3VC9P78ZyoYjcFcH2TPZSsSI7utu0cHQytVHR4ReiOUM2Hhb_Z',
  );

  static final List<_ActivityCardData> _smallBottomRow = [
    const _ActivityCardData(
      title: 'Artisan Gelato Tour',
      description: 'Taste 10 authentic flavors from family-run cremerias.',
      rating: '5.0',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCVL3cE8n3_oNPspscfUQXslZdH6ypS5R8RVNh2syg9xg9VAFmT8vVv_3-z8jElJ2ZAXB3GZwSpm4xR9X310J5T9mNQ8O-6Ygyb2xFq6mFV9640XvL-l5_py-y8xO1UgYus2sFpL5hS4xvf-bOrkAZOFA9VOphBe5QxHUltJTbmyozrkbI12hBPErnIt-SCFqgFeacIOOT3inGQL1aRzXytBPDYJAUWexfCBsJ3YFmfBHmIrDjtWTWn3jU47OWJ_lCJYiWZxEqES9qW',
    ),
    const _ActivityCardData(
      title: 'Ruins & Relics Guided',
      description:
          'A deep dive into the history of the ancient world with local experts.',
      rating: '4.9',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDIUiG-5nXPSIYXf30IoDr3J9e2ktQw0vPuXH5wGUvCjwENKQIQ7PFAHtvh4X2kiBvDuCps4y-JBhPMriuNU-E_hkLV_gJD7o1DtL1dhPadLU8L2JdJdikr0FqACx2r8_3AdZhQJLiiA8vZXiOJJHw--OtUo06q7Seip9cOhDQKRd5aFhepyoXoxucNsQauoNSHUp3sazEjIHsg6X63IScQaGIUpXea5Tx8VkdWhUs-aqeVzhXLS2INuMoI17wxPgbxTre5bSQ2jKNG',
    ),
  ];

  int _selectedChipIndex = 0;

  void _onAddTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to your trip'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Activity',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TripwiseColors.surfaceContainerHigh,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_avatarUrl),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SearchField(),
              const SizedBox(height: 16),
              _CategoryChips(
                labels: _categoryLabels,
                selectedIndex: _selectedChipIndex,
                onSelect: (i) => setState(() => _selectedChipIndex = i),
              ),
              const SizedBox(height: 28),
              Text(
                'RECOMMENDED FOR YOU',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.primary.withOpacity(0.70),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _HeroActivityCard(
                imageUrl: _heroImageUrl,
                title: 'Cliffside Alfresco Dining',
                description:
                    'Experience authentic local flavors with an unobstructed view of the Amalfi coast.',
                rating: '4.9',
                onAdd: _onAddTap,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Activities',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: textTheme.labelLarge?.copyWith(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PopularActivitiesGrid(
                topRow: _smallTopRow,
                wide: _wideCard,
                bottomRow: _smallBottomRow,
                onAdd: _onAddTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(Icons.search_rounded, color: TripwiseColors.outline),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        hintText: 'Find locations or activities...',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: TripwiseColors.onSurfaceVariant.withOpacity(0.6),
        ),
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: TripwiseColors.primary.withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _CategoryChip(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? TripwiseColors.secondaryContainer
              : TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: TripwiseColors.secondary.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected
                  ? Colors.white
                  : TripwiseColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroActivityCard extends StatelessWidget {
  const _HeroActivityCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.onAdd,
  });

  final String imageUrl;
  final String title;
  final String description;
  final String rating;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.80),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TOP RATED',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.80),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 22),
                    label: const Text('Add to Trip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TripwiseColors.secondaryContainer,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                      elevation: 8,
                      shadowColor: TripwiseColors.secondary.withOpacity(0.30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularActivitiesGrid extends StatelessWidget {
  const _PopularActivitiesGrid({
    required this.topRow,
    required this.wide,
    required this.bottomRow,
    required this.onAdd,
  });

  final List<_ActivityCardData> topRow;
  final _ActivityCardData wide;
  final List<_ActivityCardData> bottomRow;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _SmallActivityCard(data: topRow[0], onAdd: onAdd)),
            const SizedBox(width: 16),
            Expanded(child: _SmallActivityCard(data: topRow[1], onAdd: onAdd)),
          ],
        ),
        const SizedBox(height: 16),
        _WideActivityCard(data: wide, onAdd: onAdd),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SmallActivityCard(data: bottomRow[0], onAdd: onAdd),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SmallActivityCard(data: bottomRow[1], onAdd: onAdd),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallActivityCard extends StatelessWidget {
  const _SmallActivityCard({required this.data, required this.onAdd});

  final _ActivityCardData data;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(data.imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _AddIconButton(onTap: onAdd),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RatingRow(rating: data.rating),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WideActivityCard extends StatelessWidget {
  const _WideActivityCard({required this.data, required this.onAdd});

  final _ActivityCardData data;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.expand(
              child: Image.network(data.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RatingRow(rating: data.rating),
                            const SizedBox(height: 4),
                            Text(
                              data.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _WidePrimaryAddButton(onTap: onAdd),
                    ],
                  ),
                  Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 14,
          color: TripwiseColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          rating,
          style: textTheme.labelSmall?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.add_rounded,
            size: 18,
            color: TripwiseColors.primary,
          ),
        ),
      ),
    );
  }
}

class _WidePrimaryAddButton extends StatelessWidget {
  const _WidePrimaryAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TripwiseColors.primary,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ActivityCardData {
  const _ActivityCardData({
    required this.title,
    required this.description,
    required this.rating,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String rating;
  final String imageUrl;
}
