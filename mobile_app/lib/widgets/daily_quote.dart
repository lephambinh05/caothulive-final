import 'package:flutter/material.dart';
import '../services/quote_service.dart';

class DailyQuote extends StatelessWidget {
  final TextStyle? textStyle;
  final TextStyle? authorStyle;
  final EdgeInsetsGeometry padding;

  const DailyQuote({
    Key? key,
    this.textStyle,
    this.authorStyle,
    this.padding = const EdgeInsets.all(12.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quote>(
      future: QuoteService.getDailyQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Padding(
            padding: padding,
            child: Text('Không thể tải quotes.'),
          );
        }
        final q = snapshot.data!;
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('"${q.text}"', style: textStyle ?? Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              if (q.author != null && q.author!.isNotEmpty)
                Text('- ${q.author}', style: authorStyle ?? Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
