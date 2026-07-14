/// AI Inference — interface for the on-device Logistic Regression model.
///
/// CONTRACT (PRD §1.3 / §3.2 / §7.1):
/// The model binary is an artifact provided separately from this app; this file
/// defines the integration contract so the trained model can be plugged in
/// without touching call sites. The following invariants must hold once the
/// real runtime is implemented:
///
///   1. loadModel(path): load the model file (ONNX Runtime or TFLite), validate
///      its signature/version, and set [isLoaded]. Must run fully on-device.
///   2. classify(domText): preprocess the DOM text (tokenize + Bag-of-Words
///      features per the proposal), run the Logistic Regression model, and
///      return a probability in [0.0, 1.0].
///   3. Decision threshold: a score >= 0.72 is treated as gambling content and
///      triggers blocking + Pattern Interrupt. This threshold mirrors the stub
///      below and the Windows native classifier.
///   4. Privacy: no DOM text, URL, or raw page data ever leaves the device.
///
/// Until the real runtime is wired in, the stub below provides a keyword-based
/// fallback so the app is functional end-to-end. Replace the bodies of
/// [loadModel] and [classify] only; do not change their signatures.
class AIInferenceStub {
  static const double _gamblingThreshold = 0.72;

  static bool _modelLoaded = false;
  static String _modelVersion = '';

  /// Probability at or above which DOM text is classified as gambling content.
  static double get gamblingThreshold => _gamblingThreshold;

  /// Load the AI model binary from storage.
  static Future<bool> loadModel(String modelPath) async {
    // TODO: Load ONNX/TFLite model binary and initialize the runtime.
    // 1. Load the model file from [modelPath].
    // 2. Initialize the inference runtime (ONNX Runtime / TFLite).
    // 3. Validate model signature and version, then set _modelVersion.

    // Stub: pretend the model loaded successfully.
    _modelLoaded = true;
    _modelVersion = 'artifact-v0.3.1';
    return true;
  }

  /// Classify whether the given DOM text indicates gambling content.
  ///
  /// Returns a probability score 0.0–1.0. A value >= [gamblingThreshold]
  /// (0.72) is treated as a positive (gambling) detection.
  static Future<double> classify(String domText) async {
    if (!_modelLoaded) return 0.0;

    // TODO: Run inference on the real model.
    // 1. Preprocess the DOM text (tokenization, Bag-of-Words feature extraction).
    // 2. Run the Logistic Regression model.
    // 3. Return the probability score.

    // Stub: simple keyword-based classification (fallback only).
    final gamblingKeywords = [
      'slot',
      'casino',
      'poker',
      'judi',
      'togel',
      'betting',
      'sportbook',
      'bandar',
      'domino',
      'ceme',
      'gaple',
      'sbobet',
      'maxbet',
      'pragmatic',
      'ioncasino',
    ];

    final lower = domText.toLowerCase();
    int hits = 0;
    for (final kw in gamblingKeywords) {
      if (lower.contains(kw)) hits++;
    }

    if (hits >= 3) return 0.95;
    if (hits >= 1) return 0.75;
    return 0.05;
  }

  /// Whether the given score should trigger a block + Pattern Interrupt.
  static bool isGambling(double score) => score >= _gamblingThreshold;

  /// Get current model version.
  static String get modelVersion => _modelVersion;

  /// Check if the model is loaded.
  static bool get isLoaded => _modelLoaded;

  /// Release model resources.
  static void dispose() {
    _modelLoaded = false;
    _modelVersion = '';
  }
}
