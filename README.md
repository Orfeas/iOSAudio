# iOS ❤️ Audio - Orfeas Iliopoulos

This project is an exercise to show the features of recording and converting text to speech.

## Worth mentioning

There were a lot of difficulties with using the google "Speech to Text" and "Text to Speech" sdk for Swift in order to perform the tasks. Some manual override of the sdk was needed to fix some problems with it.

Following the API guidelines from Google's website the ```timepoints``` for the text that is being read returned as empty. To mitigate this, the option to use Apple's AVSpeechSynthesizer was added in order to show the "highlight the words being spoken" feature.

## Additional support

- Added option to use Apple's Speech Synthesizer to showcase the "highlight" feature.
- Additional logic for toggling between "Record" and "Play" was added. Disabling the other button while one is being used.
- Tapping on "Record" clears out the text in the text field in order to start over.
- A "Clear" button was added as a right bar button in the Navigation bar to be more apparent to the user how to clear the text.
- Added support for dark mode.
