import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/product.dart';
import '../../../design_system/design_system.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId, this.isEmbedded = false});

  final int productId;
  final bool isEmbedded;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<ProductDetailCubit>();
    if (cubit.state.product?.id != widget.productId) {
      cubit.loadProduct(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEmbedded) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Product'),
        ),
        body: _DetailBody(productId: widget.productId),
      );
    }
    return Scaffold(body: _DetailBody(productId: widget.productId));
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        if (state.status == ProductDetailStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductDetailStatus.error) {
          return ErrorState(
            message: state.errorMessage ?? 'Failed to load product',
            onRetry: () => context.read<ProductDetailCubit>().loadProduct(productId),
          );
        }
        final product = state.product;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }
        final theme = Theme.of(context);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImageGallery(productId: product.id, images: product.images, thumbnail: product.thumbnail),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brandDisplay,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PriceRow(product: product),
                    if (product.rating != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(label: 'Category', value: product.categoryDisplay),
                        _InfoChip(label: 'Stock', value: product.stock != null ? '${product.stock} available' : '—'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.productId, required this.images, this.thumbnail});

  final int productId;
  final List<String> images;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    final urls = images.isNotEmpty ? images : (thumbnail != null ? [thumbnail!] : <String>[]);
    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
        ),
      );
    }
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: urls.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 280,
              child: CachedNetworkImage(
                imageUrl: urls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.broken_image_rounded, size: 40, color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
          );
          return index == 0 ? Hero(tag: 'product-$productId', child: image) : image;
        },
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = product.discountedPriceDisplay != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          product.priceDisplay,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            decoration: hasDiscount ? TextDecoration.lineThrough : null,
            decorationColor: theme.colorScheme.outline,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 12),
          Text(
            product.discountedPriceDisplay!,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          if (product.discountPercentage != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
              child: Text(
                '-${product.discountPercentage!.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
