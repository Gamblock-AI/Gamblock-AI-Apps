import importlib.util
import os
import pathlib
import unittest


APP_ROOT = pathlib.Path(__file__).parents[2]
WORKSPACE_ROOT = APP_ROOT.parent
MODEL_ROOT = pathlib.Path(
    os.environ.get("GAMBLOCK_MODEL_ROOT", WORKSPACE_ROOT / "gamblock-ai-model")
)
SCRIPT = APP_ROOT / "scripts" / "export_onnx_linear_model.py"
SPEC = importlib.util.spec_from_file_location("export_onnx_linear_model", SCRIPT)
EXPORTER = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(EXPORTER)


class ExportOnnxLinearModelTest(unittest.TestCase):
    def test_accepts_a_valid_non_historic_unigram_boundary(self):
        self.assertEqual(2, EXPORTER.unigram_count_from_offsets([0, 2]))
        with self.assertRaises(ValueError):
            EXPORTER.unigram_count_from_offsets([0, 0])

    def test_checked_in_artifact_exports_without_fixed_vocabulary_size(self):
        artifact = EXPORTER.export_model(
            MODEL_ROOT / "models/gamblock_logistic_regression.onnx",
            MODEL_ROOT / "models/gamblock_hybrid_metadata.json",
        )
        self.assertGreater(len(artifact["unigram_weights"]), 0)
        self.assertGreater(len(artifact["bigram_weights"]), 0)
        self.assertEqual(14, len(artifact["url_features"]))


if __name__ == "__main__":
    unittest.main()
