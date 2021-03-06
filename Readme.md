# COVID-19 Detection using AI
Detection of COVID-19 using Skytells's DeepBrain for Apple's CoreML.

[![Generic badge](https://img.shields.io/badge/Build-Stable-green.svg)](https://github.com/skytells-research/Covid19-AI-Detection)
[![Generic badge](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://github.com/skytells-research/Covid19-AI-Detection)
[![Generic badge](https://img.shields.io/badge/SQC-PASS-green.svg)](https://github.com/skytells-research/Covid19-AI-Detection)
[![Generic badge](https://img.shields.io/badge/Language-Swift-orange.svg)](https://github.com/skytells-research/Covid19-AI-Detection)
[![Generic badge](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/skytells-research/Covid19-AI-Detection)

## Abstract
COVID-19 has widely spread all over the world since the first case was detected at the end of 2019.
Early diagnosis of the disease is important for treatment and the isolation of the patients to prevent the virus spread.

[![N|Solid](https://www.itnonline.com/sites/itnonline/files/styles/content_large/public/CovidHeatMaps.gif?itok=pqBOobN1)](https://github.com/skytells-research/Covid19-AI-Detection)

> Representative examples of the attention heatmaps generated using Grad-CAM method for (a) COVID-19, (b) CAP, and (c) Non-Pneumonia. The heatmaps are standard Jet colormap and overlapped on the original image, the red color highlights the activation region associated with the predicted class. COVID-19 = coronavirus disease 2019, CAP = community acquired pneumonia. Image courtesy of the journal Radiology

The DeepBrain model, was developed to extract visual features from 4,356 computed tomography (CT) exams from 3,322 patients for the detection of COVID-19. Community acquired pneumonia (CAP) and non-pneumonia CT exams were included to test the robustness of the model.
The per-exam sensitivity and specificity for detecting COVID-19 in the independent test set was 90 percent and 96 percent, respectively.

## Background
The 2019 novel coronavirus (COVID-19) presents several unique features. While the diagnosis is confirmed using polymerase chain reaction (PCR), infected patients with pneumonia may present on chest X-ray and computed tomography (CT) images with a pattern that is only moderately characteristic for the human eye [Ng, 2020](https://pubs.rsna.org/doi/10.1148/ryct.2020200034). COVID-19’s rate of transmission depends on our capacity to reliably identify infected patients with a low rate of false negatives. In addition, a low rate of false positives is required to avoid further increasing the burden on the healthcare system by unnecessarily exposing patients to quarantine if that is not required. Along with proper infection control, it is evident that timely detection of the disease would enable the implementation of all the supportive care required by patients affected by COVID-19.

In late January, a Chinese team published a paper detailing the clinical and paraclinical features of COVID-19. They reported that patients present abnormalities in chest CT images with most having bilateral involvement [Huang 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30183-5/fulltext). Bilateral multiple lobular and subsegmental areas of consolidation constitute the typical findings in chest CT images of intensive care unit (ICU) patients on admission [Huang 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30183-5/fulltext). In comparison, non-ICU patients show bilateral ground-glass opacity and subsegmental areas of consolidation in their chest CT images [Huang 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30183-5/fulltext). In these patients, later chest CT images display bilateral ground-glass opacity with resolved consolidation [Huang 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30183-5/fulltext).

COVID is possibly better diagnosed using radiological imaging [Fang, 2020](https://pubs.rsna.org/doi/10.1148/radiol.2020200432) and [Ai 2020](https://pubs.rsna.org/doi/10.1148/radiol.2020200642).

## Motivation

While PCR tests offer many advantages they are physical things that require shipping the test or the sample. X-ray machines can be plugged in to screen patients as long as they have electricity.
Imagine a future where we run out of tests and then the majority of radiologists get sick. AI tools can help general practitioners to triage and treat patients.
Companies are developing AI tools and deploying them at hospitals [Wired 2020](https://www.wired.com/story/chinese-hospitals-deploy-ai-help-diagnose-covid-19/). We should have an open database to develop free tools that will also provide assistance.

## Goal

Our goal is to use these images to develop AI based approaches to predict and understand the infection.


## Test Results
When passing an X-Ray image to the model, it analyzes the image deeply and respond with classification results

[![N|Solid](images/test-1.png)](https://github.com/skytells-research/Covid19-AI-Detection)

## Getting Started

### Requirements
- Xcode 10.3+
- iOS 12.0+
- Swift 4.2
- DeepBrain CoreML Model

### Model

The DeepBrain model was trained with more than 16,000 images in high resolution

#### PRECISION RECALL
| Class   |      Precision(%)      |  Recall(%) |
|----------|:-------------:|------:|
| BacterialPneumonia |  94.74 | 85.71 |
| ViralPneumonia |    92.31   |   97.30 |
| Covid19 | 98.57 |    100.00 |
| Normal | 100.00 |    97.22 |


#### TRAINING AUGMENTATIONS
| Augment Data   |    Status    |
|----------|----:|
| Noise |✔︎ |
| Flip |✔︎ |
| Crop |✔︎ |
| Blur |✔︎ |
| Expose |✔︎ |
| Rotate |✔︎ |

#### Type

Image Classifier

##### Classifiers
- `ImageClassifier`
    - Regular ImageClassifier Class.
- `XRayClassifier`
    - Quick detection - low accuracy of detection ratio
- `DeepClassifier`
    - Takes some time for detection - high accuracy of detection ratio

##### Detection Ability
The DeepBrain model was trained to detect the following:

- COVID-19
- Bacterial Pneumonia
- Viral Pneumonia

The model responds with `Normal` incase of none of above was detected during the classification.

#### Description

The model trained to detect COVID-19 from X-Ray & CT Images.


### Install CoreML Tools
From macOS Terminal run the following command.
```sh
$ pip install coremltools
```

### Add DeepBrain to your App
Start by adding the model to your Xcode project by dragging the model into the project navigator.
A new object with the name of your model and its properties will be automatically generated.
You can see information about the model by opening it in Xcode.
When viewing mine, we can see the model type and the inputs/outputs we configured when converting the model.

#### Setup Vision
First of all we need to create a method to load DeepBrain model and setup the live vision.
```swift
func setupVision() {
        // Setup Vision parts
        guard let modelURL = Bundle.main.url(forResource: "DeepBrain", withExtension: "mlmodelc") else {
            print("Model file is missing")
          return
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
  }
```

Then, Call this method on `viewDidLoad()` method.

```swift
override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
  }
```

#### Making Predictions
Simply call the prediction method to get our predictions.

```swift
func predict(image: UIImage) {
    do {
        if let resizedImage = resize(image: image, newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() {
            let model = DeepBrain()
            let prediction = try model.prediction(data: pixelBuffer)

        }
    } catch {
        print("Error while doing predictions: \(error)")
    }
}
```
#### Realtime Prediction
You can use DeepBrain for Realtime prediction by creating a method with:

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

  // Get the pixel buffer from the capture session
  guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

  // load the Core ML model
  guard let visionModel:VNCoreMLModel = try? VNCoreMLModel(for: DeepBrain().model) else { return }

  //  set up the classification request
  let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassification)

  // perform the machine learning classification
  do {
		  try self.visionSequenceHandler.perform([classificationRequest], on: pixelBuffer)
    } catch {
		    print("Throws: \(error)")
	}
}
```

Now, Create a method to handle classifications

```swift
// MARK - Core ML Classification

func handleClassification(request: VNRequest, error: Error?) {
  guard let observations = request.results else {

    // Nothing has been returned so we want to clear the label.
    updateClassificationLabel(labelString: "")

    return
  }

  let classifications = observations[0...3]
          .compactMap({ $0 as? VNClassificationObservation}) // discard any erroneous results
    .filter({ $0.confidence > 0.1 }) // discard anything with less than 10% accuracy.
    .map(self.textForClassification) // get the text to display

    if (classifications.count > 0) {
      // update the label to display what we found
      updateClassificationLabel(labelString: "\(classifications.joined(separator: "\n"))")
    } else {
      // nothing matches our criteria, so clear the label
      updateClassificationLabel(labelString: "")
    }

}
```

Let's update our classification results

```swift
func updateClassificationLabel(labelString: String) {
  // We processed the capture session and Core ML off the main thread, so the compleetion handler was called onthe the same thread
  // So we need to remember to get the main thread again tp update the UI

  DispatchQueue.main.async {
    self.textLayer?.text = labelString
  }
}
```

Finally
```swift
func textForClassification(classification: VNClassificationObservation) -> String {
  // Mapping the results from the VNClassificationObservation to a human readable string
  let pc = Int(classification.confidence * 100)
  return "\(classification.identifier)\nConfidence: \(pc)%"
}
```
## Languages
The app was manually translated to
* 🇺🇸 English (US)


## MIT License

Copyright (c) 2020 Skytells, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
