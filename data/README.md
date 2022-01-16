# Data

This folder contains data processing and quality assurance files, used to prepare the clinical and model development datasets. A description of each file is provided below.

## Augmentation and Rebalancing

The script takes the source database of age-labelled photographs and creates a balanced dataset for training via augmentation and randomized rebalancing. The user defines a target number of samples per age category, age range of the processed dataset, and batch size for augmentation. The augmentation is done using the ImageDataGenerator functionality in Keras:

```
# example instantiation of ImageDataGenerator object for augmentation
datagen = ImageDataGenerator(
        # paramaters for augmentation (shifts, rotations, flips, shear, etc.)
        samplewise_center = False,
        samplewise_std_normalization = False,
        rotation_range=20,
        width_shift_range=0.1,
        height_shift_range=0.1,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='constant')
 ```

The randomized rebalancing randomly shuffles samples from each each category to supplement the augmented samples until the target number of samples per age category is achieved, in order to achieve an approximate uniform distribution

![image](https://user-images.githubusercontent.com/25285692/149670666-3b30e552-1458-4d9f-a8b5-2a667ceaf7b4.png)




