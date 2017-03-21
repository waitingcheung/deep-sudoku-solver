# Deep Sudoku Solver
A Sudoku Solver that leverages [TensorFlow](https://www.tensorflow.org) and [BNNS](https://developer.apple.com/reference/accelerate/bnns) of iOS 10 SDK for deep learning.

## Usage

1. Add a picture of sudoku puzzle from the photo library.
2. Import the picture into a puzzle.
3. Edit any digits not correctly predicted.
4. Solve the puzzle.
5. Save the solution to the photo library or share it to SNS or other apps.

## Development

The steps below illustrate how to prepare your own training data for TensorFlow and use the training results for prediction in BNNS of iOS 10 SDK.

### Exporting Models from TensorFlow

I use the Chars74K image dataset for training. My trained models are in the folder [Assets.xcassets](https://github.com/waitingcheung/deep-sudoku-solver/tree/master/Assets.xcassets) with the filename ``model-h#[b|w]-*.dataset``. To train your own models, follow the steps below.

1. Resize your images to dimension of 28x28.
2. Label your images and split them into training and testing data.
3. Convert your data into the MNIST format using [JPG-PNG-to-MNIST-NN-Format](https://github.com/gskielian/JPG-PNG-to-MNIST-NN-Format)
4. [Install TensorFlow](https://www.tensorflow.org/install/)
5. Put your data ``[train|test]-[images|labels]-idx[1|3]-ubyte.gz`` in the [scripts](https://github.com/waitingcheung/deep-sudoku-solver/tree/master/scripts) folder.
6. Run [``mnist-predict-from-model.py``](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/scripts/mnist-predict-from-model.py) to get the models.
7. Import the models to the Asset Catalog in XCode.

### Predicting Labels from Images Using BNNS

1. Add the following files to your project. 
- [BnnsBuilder.swift](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/Deep%20Sudoku%20Solver/BnnsBuilder.swift)
- [ImageMagic.swift](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/Deep%20Sudoku%20Solver/ImageMagic.swift)
- [MnistData.swift](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/Deep%20Sudoku%20Solver/MnistData.swift)
- [MnistNet.swift](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/Deep%20Sudoku%20Solver/MnistNet.swift)
- [ViewModel.swift](https://github.com/waitingcheung/deep-sudoku-solver/blob/master/Deep%20Sudoku%20Solver/ViewModel.swift)

2. Use the following script for prediction.
```swift
let magic = ImageMagic()
let ai = MnistNet()
guard let data = magic.mnistData(image: UIImage)
    else {
        return
}
let predicted: Int = ai.predict(input: data)
// Process your predicted label
```

## Credit

I reused soruce code and configurations from:
- [Using TensorFlow models in iOS BNNS](https://github.com/paiv/mnist-bnns)
- [Tutorial on UICollectionViewCell](http://randexdev.com/2014/08/uicollectionviewcell/)
- [Creating a grid of UITextField in UICollectionView](http://stackoverflow.com/questions/35791362/swift-creating-grid-of-many-text-fields)
- [Using CIAreaAverage to compute the average color of a CIImage](https://github.com/pauljones13/BubbleWrap/blob/master/CIImage+AverageColour.swift)
- [Converting a color image to gray scale](http://myxcode.net/2015/08/30/converting-an-image-to-black-white-in-swift/)
- [Tutorial on UIActivitiyViewController](http://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift)
- [Tutorial on moving a view up when covered by the keyboard](http://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field)
- [Swift implementation of Peter Norvig's constraint based sudoku solver](https://github.com/pbing/Sudoku-Solver)

