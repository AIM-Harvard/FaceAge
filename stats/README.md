# Statistical Analysis Code

This folder contains all the code used to generate the plots from the Main Manuscript (`main`) and the Extended Data (`extended`).

<br>

Statistical and survival analyses were performed in Python 3.6.5 using the [Lifelines library](https://github.com/CamDavidsonPilon/lifelines), as well as NumPy and SciPy libraries, and in the open-source statistical software platform, R.

The clinical endpoint was overall survival (OS). Actuarial survival curves for stratification of risk groups by overall survival were plotted using the Kaplan Meier (KM) approach, right-censoring patients who did not have the event or were lost to follow-up. All hypothesis testing performed in the study was two-sided, and paired tests were implemented when evaluating model predictions against the performance of a comparator for the same data samples. Differences in KM survival curves between risk groups were assessed using the logrank test. Univariable and multivariable analysis via the Cox proportional hazards (PH) model was carried out to adjust for the effect of clinical covariates such as gender, disease site, smoking status, performance status and treatment intent.
