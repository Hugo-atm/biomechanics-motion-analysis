# Markerless Gait Analysis: YOLOv7 vs. OpenPose

**Undergraduate research project · Mechanical Engineering, Institut Teknologi Bandung (ITB) · 2023**

Supporting Python/Jupyter and MATLAB analysis scripts for the undergraduate thesis **“Comparative Study of YOLOv7 and OpenPose for Gait Analysis with Marker Method as Baseline.”** The study assessed how accurately two markerless pose-estimation methods reconstructed **right-knee motion in the sagittal plane**, using an HSV-based, passive-marker motion-capture workflow as the comparison reference.

> **Scope:** This is a collection of research and analysis scripts, not a packaged YOLOv7/OpenPose implementation or a one-command reproducibility pipeline. The thesis results reported below come from the completed study; the datasets, pretrained pose-estimation frameworks, and all acquisition assets are not included here.

## Research question and motivation

Marker-based motion capture can provide useful reference measurements, but it also requires markers, acquisition hardware, setup effort, and additional processing. Markerless pose estimation could make movement analysis less intrusive and easier to use. Previous work in the ITB biomechanics laboratory identified joint-position and joint-angle errors with OpenPose, motivating an assessment of a different model.

**Question:** For laboratory gait recordings, how do **YOLOv7-Pose** and **OpenPose** compare when estimating knee angle relative to an HSV marker-tracking reference?

This project focuses on **comparative evaluation and signal processing**, rather than training a new pose-estimation network.

## Study design

| Item | Thesis study |
| --- | --- |
| Participants | 15 male participants, ages 20–30, with normal BMI |
| Task | Walking at each participant's comfortable speed |
| Field of view | Right lower limb, sagittal plane |
| Acquisition | GoPro video, with passive markers for the reference method |
| Reference | HSV color-based marker tracking |
| Markerless methods | YOLOv7-Pose and OpenPose |
| Reconstruction | 2D direct linear transformation (2D-DLT) camera calibration |
| Target measurement | Knee angle, in degrees |
| Evaluation | Pearson correlation, root mean squared error (RMSE), and a two-sample t-test reported in the thesis |

The study is specific to these conditions; it does not establish accuracy for 3D movement, other body joints, different camera arrangements, clinical use, or a broader population.

## Processing and analysis workflow

1. **Acquire and calibrate recordings.** Record gait and calibration footage; obtain the HSV marker-tracking reference and solve a 2D-DLT mapping using calibration control points.
2. **Prepare markerless video.** Extract video frames and construct masks around marker locations for the marker-removal/inpainting stage used in the thesis. The notebooks here implement frame and mask preparation; the complete LaMa inpainting model is not bundled.
3. **Extract pose trajectories.** Process YOLOv7 and OpenPose outputs to obtain hip, knee, and ankle trajectories. The repository includes OpenPose JSON-to-CSV utilities; it does **not** include the full inference environments or trained model weights.
4. **Handle imperfect trajectories.** Explore linear or cubic-spline interpolation for missing/zero coordinates, followed by Butterworth low-pass filtering.
5. **Reconstruct and compare knee angles.** Use MATLAB scripts for 2D calibration/coordinate reconstruction and knee-angle calculations, and Python notebooks to plot/reference-match time series.
6. **Quantify agreement.** Compute Pearson correlation and RMSE, examine the effect of a per-series mean-offset correction, and conduct the statistical tests documented in the thesis.

**Illustrative data flow**

```text
Gait video + calibration footage
          |
          +--> HSV passive-marker tracking ------------------+
          |                                                   |
          +--> frame extraction --> marker masks/inpainting  |
                                       |                       |
                                  YOLOv7 / OpenPose            |
                                       |                       |
                                joint-coordinate CSVs          |
                                       |                       |
                           interpolation / filtering           |
                                       |                       |
                           2D calibration and knee angle <-----+
                                       |
                               plots, r, RMSE, t-test
```

This summarizes the research methodology, not an executable command-line pipeline.

## Main findings from the undergraduate thesis

The following values are **averages across the 15 subjects**, taken from Tables 4.1 and 4.2 of the thesis:

| Metric | YOLOv7 | OpenPose |
| --- | ---: | ---: |
| Pearson correlation with HSV reference | 0.99 | 0.98 |
| RMSE **before** mean-offset correction | 4.37° | 4.66° |
| RMSE **after** mean-offset correction | **2.24°** | **3.30°** |

Both methods reproduced the general knee-angle trajectory well. YOLOv7 had the lower average error in this experiment, especially after compensating for differences in the average knee-angle level. The thesis also reported statistically significant differences using **independent two-sample Student's t-tests** (Table 4.3).

**Interpretation cautions:** The corrected RMSE figures should not be presented as uncorrected prediction errors. The offset uses the reference trajectory's mean, so it is an *evaluation-time alignment*, not a deployable reference-free correction. The thesis used an independent-samples test despite evaluating both methods on the same subjects; a paired analysis would be worth investigating in any follow-up study. These results are not evidence that a YOLOv7 model was fine-tuned or newly trained in this repository.

## Repository guide

The scripts are retained under their existing research filenames, including exploratory revisions.

| Files | Purpose |
| --- | --- |
| [`extract_frames_from_videos.ipynb`](extract_frames_from_videos.ipynb), [`Frames to video.ipynb`](Frames%20to%20video.ipynb) | Extract video frames and reconstruct video sequences |
| [`Mask generator.ipynb`](Mask%20generator.ipynb) | Generate per-frame marker masks from coordinate tables |
| [`json_to_csv_converter.ipynb`](json_to_csv_converter.ipynb), [`Jsonfile2csv_confidence_score.ipynb`](Jsonfile2csv_confidence_score.ipynb) | Parse OpenPose JSON keypoints; one variant selects the detected person using joint-confidence scores |
| [`Linear_interpolation_OpenPose.ipynb`](Linear_interpolation_OpenPose.ipynb), [`Cubic_spline_interpolation.ipynb`](Cubic_spline_interpolation.ipynb) | Explore interpolation of zero-valued pose coordinates |
| [`Butterworth_filtering.ipynb`](Butterworth_filtering.ipynb) | Fourth-order low-pass filtering (script assumes 120 Hz sampling) |
| [`PengolahanData_DLT2D (1).m`](PengolahanData_DLT2D%20%281%29.m), [`data_processing_final.m`](data_processing_final.m), [`Dataprocessing.m`](Dataprocessing.m) | MATLAB camera calibration, position reconstruction, and joint-angle processing variants |
| [`Knee_angle_comparison_new.ipynb`](Knee_angle_comparison_new.ipynb), [`Knee_angle_plot.ipynb`](Knee_angle_plot.ipynb) | Visual comparison of knee-angle trajectories |
| [`Marker_Trajectory_comparison.ipynb`](Marker_Trajectory_comparison.ipynb), [`Marker_Trajectory_plot.ipynb`](Marker_Trajectory_plot.ipynb) | Compare reconstructed marker trajectories |
| [`Pearson_correlation_RMSE.ipynb`](Pearson_correlation_RMSE.ipynb), [`Student_t_test.ipynb`](Student_t_test.ipynb) | Quantitative and statistical analysis |

Other MATLAB processing revisions and duplicate/backup notebooks are preserved for research provenance; similarly named files should not be assumed to be independent implementations.

## Environment and reproduction

**Python-side libraries observed in the notebooks:** Python 3, Jupyter, pandas, NumPy, SciPy, Matplotlib, OpenCV (`cv2`), and `tqdm`. **MATLAB** is used for calibration and coordinate reconstruction.

To explore individual notebooks:

```bash
python -m venv .venv
# Activate the environment using your operating system's command
python -m pip install notebook numpy pandas scipy matplotlib opencv-python tqdm
jupyter notebook
```

You will need to **edit local input/output paths**, supply appropriately formatted data, and check coordinate and sampling-rate assumptions. Several research notebooks reference original Windows directories, original participant CSVs, and interactive input. The provided code has not been independently executed end-to-end in a fresh environment. Dependencies are not pinned, and the complete acquisition/inpainting/pose-model toolchains are external.

## Limitations and next steps

- **2D only:** Depth effects, camera placement, and out-of-plane motion can affect reconstructed angles.
- **Missing data and interpolation:** A smoothed signal can look better without necessarily preserving all real movement characteristics.
- **Evaluation scope:** Small, homogeneous sample and comfortable walking, not higher-speed or diverse clinical populations.
- **Model development:** Future experiments could fine-tune YOLOv7 using approved local reference data and compare on held-out subjects.
- **More robust validation:** Evaluate paired statistics, uncertainty, alternative alignment strategies, and 3D or multi-view calibration.

## Thesis, authorship, and acknowledgments

**Adonis Thirafi Hugo Mafaza (2023).** *Comparative Study of YOLOv7 and OpenPose for Gait Analysis with Marker Method as Baseline.* Undergraduate thesis, Mechanical Engineering, Institut Teknologi Bandung.

The thesis identifies **Dr. Eng. Ir. Ferryanto** as main supervisor and **Prof. Ir. Andi Isra Mahyuddin** as co-supervisor, and acknowledges earlier laboratory work, guidance, and gait data supplied by other researchers. The work builds on existing **YOLOv7, OpenPose, HSV marker-tracking, and LaMa** methods; it does not claim authorship of those frameworks. The presence of an experimental script does not establish that every line originated from one person; third-party code should retain any applicable attribution and licensing.

No subject recordings or data are included. Reuse of data, models, or borrowed code remains subject to their respective permissions.

---
*Academic research portfolio · methods and figures are described according to the 2023 thesis; source scripts are historical research artifacts.*