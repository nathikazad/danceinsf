import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtTokenService {
  static const String _signingKeyId = '4UHhB302P5OtfwKGSJly02J8Zhwi3aB1e7dfMaq00DeQlI'; // To be filled by user
  static const String _base64PrivateKey = 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdlFIT1pUMXpFaEV0SUErVERQVEhaUWVTc1VFNks1NUYyU0FPR2s4ZUFXRzV0cUs3CnFiOEhvVUs1NDZwQlFEZjBNYTBJTVRwZ1ZFWnJ3VWlSTWJKdE9McWpQVEdZUXd5QlZGd3ZqY3pRQWdaalBMWWEKVTdrRThoczdGVWdyUnFvUzRpdVdIWnZzdzFiOVQzaTdXSWU2N2wxZGh0MEsvR3A1dHlnTDB0MU9yUlF6USs2bwpWbldTOGhoRHdDUEcyWUFwdThKTVpmMVNjU2hVSHpIU1JjcDFBUlNGcVVMVFlxSWRtVHVWbzJJZUR3M3dmUVhkCi93SzQ4b2xpNVFjQ3NzelZMQU5rQ05RMWVtYVNMM0Y4UlpFZkdITmVuMHJNakVkWFR3amJPVHVqZS9vc2g3MFMKRmR5SnVlY3luWFpWVW9meXk2MmY2elBNOE9WQVRNR3EwWFdJRndJREFRQUJBb0lCQUFYNEI2SkUydHh5M3hUegpIa3dReURkQVBQbGlFUFNOcnJFRHI4NVVPZml3aUdLUEtHbGM3TFhDc0xJb09mVk5qeEJUNFpLdkZabXp1NkFZCkFFQ0IzUUhSOWI1dlVZVlVpMiswUUVBMGUvYUVhSFU0dEZqT2hWY2hWYS8vWG5hQWY5RFZXdUZHZjZkUG1QZW8KaUJUQi9KSkloVFZHeDhaZTZuSEdwRkR5eDVMMFVYYXdubkJwTUdYR0tva1dhTUIxTFVWcUxFdXJZMkN6M0kzWgpvZXh4QU11dzl1amRZWWNJbFFtaDRVNkhVY3M3ajFLOXc5Z0w4andLd0ZuT2tHcGd2Mm5rcmxNOFYrdFNhZTVsCi9xeXRRR0cwM3BacU00Z2JuTkJuUk1HNmluNlJkUjBPTDRSdlhBRnBTUW9nQzlwYkpjR1dMMFRKZVFhNjUxcVAKTTcraHNVRUNnWUVBMnBvU1Y5SzgyeDdmdnNualNxRE5qdDAyV0pqSVRlUnJrYVY4S1ROdlBSVU9VeW93RG1obwpUL0xQM3VaSS9lbjN5bituUEUrcWFRSjV3WDhuR0t1YkF3SHIvRDdxSnRVd0FBMWI2ZDlkeHphc09PclMvWmFrCmdIMmt3RmhjdlYvMG1YT1RBUVlYWE4yYTJsVi9JM0ZMc0RNdmh1ZHNRd0xkNTBqR25YNGxpTGNDZ1lFQTNWZVkKZVhQazBTKzJwWFlkUzFhdVdid0Y2QnlTMmp4dW1KNzFlTktxRUNHU0xzNkhtL3Y4TWpuVWNsNkZPN056NjVIMApENVppb0ZhdmVVQzhqVmxqVXNQenJEM2FxTGxLM2J0WTJkbmNkcVVqVis0Q3VITmZCbEEvT2FMOCtESTFzRW41CmJTS0xtcStHOWNXZ0hta1crVkllbGFoeDEvN0c1T1Q5TXYxSzI2RUNnWUVBaFFJaUR4WEdtM3pabnZpd040UkkKRHBsQ3EvMnFRdHF0S04yTUFuV3RSWGsrVWhQbFVaN3RlVmZBYTF1ckpmUHFOV2dlbFcvVHZEa3BaRGE5enlENwpISVZhMVF4aTVHWHE0dDArQTd0SkVDR1FBTUhBeDFPVm5Dald5Y0g2QzdBSzRDT1dXcFVlT2Y4TWJiUi91MDBBClJLR2dWWEVTU21QQUtTMzZ5M0VwM1ZrQ2dZQVFNQXpWclJVcCsxeFhRNGttN21MMzZ4bGZmVjk4R0hsYUxoM3oKeFN4czI1ZXVWcXB5VFA2SHlkVHd2RnJ3SDlLMWdzb2ZyYmJ1MVFnbVRRYTlLN0ZvNXkzV0Jmd001T2hGeVNMWgpZK2FNd3MwUDdEZEV1Q05WK2Q1MTM2YXluREZ6QUNYK3hrMEJkaDdmc0tGaU4vdFhKcHRZQkthMnprcExpVGUvClYrajJvUUtCZ1FDY0N2dGZ5YXZaZUxmRUpJVHhDVVFUUlJSbjlDem9Zbk1Qa25vS0dZd3crWE5Xenh2SnN0TWUKMTdzRnlpYlVrSW9kS3lwY3pOOUgxMDR4alNTa0RqdStRaEsxelhKWFFoK2JkL090a0Z2RmVUMDQ2QndKSldZNQpCRDBjWXo0R1FtbHI3TE5ONy9SWmRJc1VXRFh0MldvNkZ6NEliYWh4T210eGlxTERFOXdHVHc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo='; // To be filled by user

  /// Generates a JWT token for Mux stream access
  /// 
  /// [playbackId] - The Mux playback ID for the stream
  /// [expiresIn] - Token expiration time in seconds (default: 1 hour)
  /// Returns a signed JWT token string
  static String generateToken({
    required String playbackId,
    int expiresIn = 3600, // 1 hour default
    bool forThumbnail = false,
  }) {
    try {
      // Decode the base64 private key to get the PEM string
      final privateKeyBytes = base64Decode(_base64PrivateKey);
      final privateKey = utf8.decode(privateKeyBytes);

      // Create JWT payload
      final payload = {
        'sub': playbackId,
        'aud': forThumbnail ? 't' : 'v',
        'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn,
        'kid': _signingKeyId,
      };

      // Create JWT
      final jwt = JWT(
        payload,
        issuer: 'https://stream.mux.com',
      );

      // Sign with RS256 algorithm using RSAPrivateKey
      final token = jwt.sign(
        RSAPrivateKey(privateKey),
        algorithm: JWTAlgorithm.RS256,
        expiresIn: Duration(seconds: expiresIn),
      );

      return token;
    } catch (e) {
      throw Exception('Failed to generate JWT token: $e');
    }
  }

  /// Generates a complete Mux stream URL with JWT token
  /// 
  /// [playbackId] - The Mux playback ID for the stream
  /// [expiresIn] - Token expiration time in seconds (default: 1 hour)
  /// Returns the complete stream URL with token
  static String generateStreamUrl({
    required String playbackId,
    int expiresIn = 3600,
    bool signed = false,
  }) {
    print('Generating stream URL for $playbackId $signed');
    if (signed) {
      final token = generateToken(playbackId: playbackId, expiresIn: expiresIn);
      return 'https://stream.mux.com/$playbackId.m3u8?token=$token';
    } else {
      return 'https://stream.mux.com/$playbackId.m3u8';
    }
  }

  static String generateThumbnailUrl({
    required String playbackId,
    bool signed = false,
  }) {
    if (signed) {
      final token = generateToken(playbackId: playbackId, expiresIn: 3600, forThumbnail: true);
      return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop&token=$token';
    } else {
      return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop';
    }
  }
}