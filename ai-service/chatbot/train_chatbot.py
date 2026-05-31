import json
import pickle
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline

# Load intents
with open('intents.json', 'r') as f:
    data = json.load(f)

# Prepare training data
sentences = []
labels = []

for intent in data['intents']:
    for pattern in intent['patterns']:
        sentences.append(pattern.lower())
        labels.append(intent['tag'])

print(f"Training on {len(sentences)} examples across {len(set(labels))} intents")

# Build pipeline: TF-IDF + SVM
pipeline = Pipeline([
    ('tfidf', TfidfVectorizer(
        ngram_range=(1, 2),  # unigrams and bigrams
        max_features=5000,
        stop_words='english'
    )),
    ('svm', SVC(
        kernel='linear',
        probability=True,
        C=1.0
    ))
])

# Cross validation to evaluate
scores = cross_val_score(pipeline, sentences, labels, cv=5, scoring='accuracy')
print(f"Cross-validation accuracy: {scores.mean():.2f} (+/- {scores.std():.2f})")

# Train on full data
pipeline.fit(sentences, labels)

# Save model and intents
with open('chatbot_model.pkl', 'wb') as f:
    pickle.dump(pipeline, f)

with open('chatbot_intents.json', 'w') as f:
    json.dump(data, f)

print("Chatbot model saved to chatbot_model.pkl")

# Test a few examples
test_phrases = [
    "where is my order",
    "when will it arrive",
    "cancel my delivery",
    "hello",
    "how many pending orders"
]

print("\nTest predictions:")
for phrase in test_phrases:
    prediction = pipeline.predict([phrase.lower()])[0]
    confidence = max(pipeline.predict_proba([phrase.lower()])[0])
    print(f"  '{phrase}' → {prediction} ({confidence:.0%} confidence)")