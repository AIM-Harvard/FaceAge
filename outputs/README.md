# Output

This folder stores a sample of the output from the FaceAge pipeline (`utk_hi-res_qa_res.csv`). This CSV file was obtained by processing the data folder `data/utk_hi-res_qa` [SHARED UPON PUBLICATION?] using the demo script `predict_folder_demo.py` (with the default configuration stored in `config_predict_folder_demo.yaml`), found under the `src/test` subdirectory.

The `subj_id` column contains the file name (without the extension), while the `faceage` column contains the estimation of the subject biological age **[CHECK]** computed by our pipeline:

|          subj_id          |  faceage  |
|---------------------------|-----------|
| 100_1_0_20170112213303693 | 94.32125  |
| 100_1_0_20170117195420803 | 95.265175 |
| 100_1_0_20170119212053665 | 98.09706  |
| 20_0_0_20170104230051977  | 24.914663 |
| 20_0_0_20170110232156775  | 29.671522 |
...
| 51_0_0_20170117160754830  | 49.63042  |
| 51_0_0_20170117160756480  | 56.181442 |
| 51_0_0_20170117160807782  | 59.752483 |
| 51_0_0_20170117171936642  | 68.6635   |
| 51_0_0_20170117172522285  | 56.001312 |
...
| 96_1_0_20170110173805290  | 89.467255 |
| 96_1_0_20170110182515404  | 89.93545  |
| 96_1_2_20170110182526540  | 91.92511  |
| 99_1_0_20170120133837030  | 92.09139  |
| 99_1_2_20170117195405372  | 95.592224 |


The CSV file `utk_hi-res_qa_res-ext_data.csv` is very similar copy of the aforementioned that incorporates all the information needed to reproduce the first Extended Data figures. This CSV has been generated from the Google Colab Notebook `data_processing_demo.ipynb` [link to the notebook here]:

```


```



