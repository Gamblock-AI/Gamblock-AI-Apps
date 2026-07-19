class GoogleAuthResult {
  const GoogleAuthResult({required this.idToken, this.nonce});

  final String idToken;
  final String? nonce;
}
