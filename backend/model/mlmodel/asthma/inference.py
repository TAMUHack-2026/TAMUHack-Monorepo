import numpy as np
import pandas as pd
import joblib

class AsthmaRiskModel:
    def __init__(self, artifact_path: str):
        artifact = joblib.load(artifact_path)
        self.model = artifact["model"]
        self.features = artifact["features"]

    def _to_frame(self, x):
        # Accept dict (single example), list of dicts, or DataFrame
        if isinstance(x, dict):
            X = pd.DataFrame([x])
        elif isinstance(x, list):
            X = pd.DataFrame(x)
        elif isinstance(x, pd.DataFrame):
            X = x.copy()
        else:
            raise TypeError("Input must be dict, list[dict], or pandas DataFrame.")
        return X

    def predict_proba(self, x):
        X = self._to_frame(x)

        # Ensure all required features exist
        missing = [f for f in self.features if f not in X.columns]
        if missing:
            raise ValueError(f"Missing required features: {missing}")

        # Enforce feature order
        X = X[self.features]

        # Validate numeric
        X = X.apply(pd.to_numeric, errors="raise")

        # Probability of class 1 (asthma)
        return self.model.predict_proba(X)[:, 1]

    def predict(self, x, threshold: float = 0.5):
        p = self.predict_proba(x)
        return (p >= threshold).astype(int)

    def predict_risk(self, x, threshold: float = 0.5):
        """
        Returns a dict for single input, or a list[dict] for batch input.
        """
        X = self._to_frame(x)
        probs = self.predict_proba(X)
        preds = (probs >= threshold).astype(int)

        out = []
        for i in range(len(X)):
            out.append({
                "risk": float(probs[i]),
                "label": int(preds[i]),   # 1 = asthma risk flag
                "threshold": float(threshold)
            })

        return out[0] if isinstance(x, dict) else out
    



