import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  // Override SSL untuk bypass certificate (HANYA UNTUK TESTING)
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Gambar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GambarScreen(
        imageUrl:
            'https://kpsp.himogi.my.id/storage/ilustrasi/KskyYG7FmhSq6RoFbRyIIsKaRXwcbJRKccQw2W3y.png',
      ),
    );
  }
}

class GambarScreen extends StatelessWidget {
  final String imageUrl;

  const GambarScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lihat Gambar')),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error, size: 50, color: Colors.red),
              SizedBox(height: 8),
              Text('Gagal memuat gambar'),
            ],
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
