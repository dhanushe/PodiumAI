import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const kPrimaryDark = Color(0xFF18161f);
const kPrimaryLight = Color(0xFFecedee);
const kPrimaryGray = Color(0xFF3a3941);
const kPrimaryGreen = Color(0xFF8ffed0);
const kPrimaryPurple = Color(0xFF9984d4);

class Constants {
  static String myName = '';
}

final apiKey = "AIzaSyDPISavCG_7dSteajrni9M_JedFSWxU6Vk";

// prompts to gemini
const createQuizPrompt = """
Given the lecture transcript below, please create a comprehensive quiz in JSON format that tests understanding of its key concepts, facts, and sequences. The quiz may include any combination of Multiple Choice Questions (MCQ), Fill in the Blanks, Matching, True/False, Sequence, Drag and Drop, and Short Answer Questions (SAQ). Feel free to omit any question type that doesn't align with the lecture content, and include multiple questions of the same type where appropriate to provide a thorough assessment.

Please use your judgment to decide which types of questions best fit the material covered. Not all question types are required if they don't apply. Aim to create a varied and engaging quiz that effectively tests the lecture's key points.

These are some of the learning targets the quiz should cover:
LEARNINGTARGETSINSERT

Lecture Transcript:
LECTURETRANSCRIPTINSERT


For each question in the quiz, include the following details in the JSON structure:
1. A unique identifier and the question type.
2. All necessary components for that question type, such as the question text, options for MCQs, the correct answer, and any keywords or hints for SAQs.

Below are detailed examples of how each question type should be structured in the JSON output:

MCQ Example:
{
  "id": "mcq1",
  "type": "MCQ",
  "question": "What is the capital of France?",
  "options": ["Paris", "Rome", "Berlin", "Madrid"],
  "correct_answer": "Paris"
}

Fill in the Blank Example:
{
  "id": "fitb1",
  "type": "Fill in the Blank",
  "question": "The largest planet in our solar system is ________.",
  "correct_answer": "Jupiter"
}

Matching Example:
{
  "id": "match1",
  "type": "Matching",
  "question": "Match the country with its capital.",
  "pairs": [
    {"left": "France", "right": "Paris"},
    {"left": "Italy", "right": "Rome"},
    {"left": "Germany", "right": "Berlin"}
  ]
}

True/False Example:
{
  "id": "tf1",
  "type": "True/False",
  "question": "The human body has 206 bones.",
  "correct_answer": "True"
}

Sequence Example:
{
  "id": "seq1",
  "type": "Sequence",
  "question": "Arrange the planets in our solar system in order from closest to farthest from the Sun.",
  "options": ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"],
  "correct_order": ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
}

Drag and Drop Example:
{
  "id": "dnd1",
  "type": "Drag and Drop",
  "question": "Categorize the following animals into 'Mammals' and 'Reptiles'.",
  "elements": ["Tiger", "Crocodile", "Python", "Elephant"],
  "categories": {
    "Mammals": ["Tiger", "Elephant"],
    "Reptiles": ["Crocodile", "Python"]
  }
}

SAQ Example:
{
  "id": "saq1",
  "type": "SAQ",
  "question": "Explain why photosynthesis is important to life on Earth.",
  "keywords": ["oxygen", "food", "carbon dioxide", "plants"]
}

Make sure to include multiple MCQ questions since they are usually most applicable for testing knowledge.
Create more than 5 to 10 questions in total, covering a range of topics from the lecture content.

The final output should be in a valid JSON format, tailored for dynamic quiz generation in a Flutter application. Each question should be designed to effectively evaluate comprehension of the lecture content, using the most suitable question type to engage and challenge learners.

Give me your repsonse starting with:
```json
{
  "quiz": [
    {
      "id": "mcq1",
      "type": "MCQ",
""";

const kCreateNoteSheetPrompt = """
"Given the following lecture transcript, generate comprehensive notes in markdown format. The notes should encapsulate all the key points, definitions, and important concepts mentioned throughout the lecture. Please adhere to the following markdown formatting rules:

Utilize # for titles and headers to denote hierarchy and structure. Use # for main titles, ## for sub-titles, and so on.
Emphasize key terms and phrases using *italics* for new terms or special emphasis and **bold** for very important concepts or definitions.
Include any relevant code snippets or examples by wrapping them in triple backticks (```) to distinguish them from the rest of the text.
Please ensure that:

The notes are well-organized and logically structured to reflect the flow of the lecture.
Only the allowed markdown features are used, specifically headers, italics, bold text, and code snippets.
No links to the internet are included.
Lists are not used, and no other HTML/Markdown features beyond the ones specified are incorporated into the notes.

Make sure to include these objectives in your notes, but feel free to add any additional relevant information (try to cover everything in the transcript):
LEARNINGTARGETSINSERT

Lecture Transcript:
LECTURETRANSCRIPTINSERT

Remember, the goal is to create a useful, easily navigable, and concise representation of the lecture's content that students can refer to for studying and revision."
""";

List<SafetySetting> kSafetySettings = [
  SafetySetting(
    HarmCategory.dangerousContent,
    HarmBlockThreshold.none,
  ),
  SafetySetting(
    HarmCategory.harassment,
    HarmBlockThreshold.none,
  ),
  SafetySetting(
    HarmCategory.sexuallyExplicit,
    HarmBlockThreshold.none,
  ),
  SafetySetting(
    HarmCategory.hateSpeech,
    HarmBlockThreshold.none,
  ),
  SafetySetting(
    HarmCategory.unspecified,
    HarmBlockThreshold.none,
  ),
];
