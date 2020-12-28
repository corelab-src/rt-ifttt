RT-IFTTT: SIMULATION
================= 

RT-IFTTT is an applet-based real-time IoT framework with condition-aware
flexible polling intervals. RT-IFTTT analyzes current sensor values, trigger
conditions and constraints of all the applets in the framework, and dynamically
calculates the optimal polling intervals for each sensor.

Abstract & Paper 
===============

> With a simple “If This Then That” syntax, IoT frameworks such as IFTTT and
> Microsoft Flow allow users to easily create custom applets integrating
> sensors and actuators. Since users expect their applets to respond to changed
> sensor values within a certain latency while the sensors usually have limited
> battery power, reading the sensor values at the right time point is crucial
> for the IoT frameworks to support realtime responses of the applets while
> maximizing battery lives of sensors. However, existing IoT frameworks
> periodically read the sensor data with fixed intervals without reflecting
> current sensor values and trigger conditions of applets, so the intervals are
> either too long to meet the real-time constraints, or too short wasting
> batteries of sensors. This work extends the existing IFTTT syntax for users
> to describe real-time constraints, and proposes the first real-time IoT
> framework with trigger condition-aware flexible polling intervals, called
> RT-IFTTT. RT-IFTTT analyzes current sensor values, trigger conditions and
> constraints of all the applets in the framework, and dynamically calculates
> the optimal polling intervals for each sensor.  This work collects real-world
> sensing data from 10 physical sensors for 10 days, and shows that the
> RT-IFTTT framework with the proposed schedulers executes 100 to 400 applets
> according to user-defined real-time constraints with up to 64.12% less sensor
> polling counts compared to the framework with the fixed intervals.


Requirements 
============= 

We implemented RT-IFTTT simulation  by using
[Matlab](https://mathworks.com/products/matlab.html). So there is no need to
install other libraries or frameworks except Matlab.

- Matlab R2017a or higher: We tested the codes on Matlab R2017a, but the lower
is not confirmed.
- 2 GB of free disk space: Due to the size of MNSVG model, the simulation needs
the large size of a free space. The size of generated files depends on the
amount of your sensor data.
- Time and patience: It takes at least 12 hours to simulate the situation of 400
applets with given training & sensor data. We are working on performance issues.

How-to 
======

## Easy Run 

If you are eager to reproduce the result of the paper,  just change
`num_applets` in the [`config.m`](config.m) to 100, 200, 300, 400 and type 
`run` in the command window. But we **strongly recommend you to read the 
following description** to run your own data and extensible configuration.

## Provided Data 

In order to reproduce the result, we provided the data which is used to
evaluate algorithms. [`data/sample.csv`](data/sample.csv) and 
[`data/rawdata.csv`](data/rawdata.csv) are collected data from 10 physical 
sensors that consist of 2 sets of temperature, humidity, UV index, ambient 
light, and pressure sensors. The file [`data/sample.csv`](data/sample.csv)
has training data to build a prediction model, and the file
[`data/rawdata.csv`](data/rawdata.csv) has evaluation data to evaluate 
algorithms.

Moreover, we provided the randomly generated applets which are used in the 
evaluation of the paper: `data/applet_YYY.mat` *(YYY = 100, 200, 300, 400)*.
[`s4_applet_generator.m`](DESIGN.md#s4_applet_generatorm) can generate other 
random applets; see [`s4_applet_generator.m`](DESIGN.md#s4_applet_generatorm) 
for details.

## Test Inputs 

You can use the provided sensor data ([`data/sample.csv`](data/sample.csv) and 
[`data/rawdata.csv`](data/rawdata.csv)) which is used in the paper, or you can 
give your own sensor data to test. Sensor data inputs should follow this format.
(You can see [`data/sample.csv`](data/sample.csv) as an example.)

- Training data and evaluation data: In order to run the simulation with your
sensor data, you have to provide **training data** and **evaluation data**. The
training data is used to build the MNSVG (maximum normalized sensor value
gradient) prediction model, and the evaluation data is used to evaluate the
RT-IFTTT algorithm and the baseline algorithms.
- CSV file: The data should be **comma-separated**.
- Same Header: **The first row should be a header row** which represents the
  date & time or the name of a sensor. The column of the training data and the 
  raw data should be **in the same order**.
- Date & Time: **The first column should represent the date & time** when the
  data is corrected.
- Date & Time Format: `DD-MMM-YYYY hh:mm:ss`. For example: 
  `10-Apr-2017 13:20:01`. See details in 
  [`s1_sensor_data.m`](DESIGN.md#s1_sesnor_datam)
  to change the format.


## Configuration 

In order to run the simulation, you have to look carefully the configuration
file [`config.m`](config.m). Global constants are in uppercase; you must not 
change the global constants in uppercase.

### Common variables

- `num_sensors`: The number of sensors to simulate. `num_sensors` should be
equal to the number of your given data in `sample_csv` and `rawdata_csv`. 
*Default: 10*
- `num_applets`: The number of applets to simulate. *Default: 100*
- `clear_matrix`: When you want to clear all the generated matrix, set
`clear_matrix` to 1. The script `run` will ask you again. *Default: 0*
- `rerun_from_s4`: When you don't want to re-build the prediction model and the
data, set `rerun_from_s4` to 1. Then the simulation re-generate random applets,
and run the evaluation. *Default: 0*

### s1_sensor_data

- `sample_csv`: The file path to the training data. *Default:
[data/sample.csv](data/sample.csv).*
- `rawdata_csv`: The file path to the evaluation data.  *Default:
[data/rawdata.csv](data/rawdata.csv).*

### s2_low_pass_filter
 
- `wsize`: The window size of the low-pass filter. *Default: 600*

### s3_mnsvg_model

- `delta_t`: MNSVG model takes some ∆t for prediction , not all the contiguous
∆t due to the size and the performance of the model. *Default: [1, 10, 20, ...
, 900]*

### s4_applet_generator

- `deadline`: Relative deadlines for each applet are chosen from a finite set.
*Default: [30, 60, 300, 600]*
- `rand_max` and `rand_min`: The maximum and minimum values of each sensor data
set. The number of elements should be equal to `num_sensors`.

### s6_eval_fixed

- `fix_opt_interval`: The sensor polling interval for Optimistic Fixed Interval
(Fix-Opt). *Default: 900*
- `fix_con_interval`: The sensor polling interval for Conservative Fixed
Interval (Fix-Con). *Default: 30*

### s7_eval_rt_ifttt

- `modeling_interval`: The next sampling interval required to keep the sensor
value prediction model valid. *Default: 900*
- `e`: Constant miss ratio for all the applets. *Default: 0.1*


## Run

After you edit the configuration, simply type `run` on the command window. Seat
back and watch!

- Each module from `s1` to `s5` generates a `.mat` file. If a `.mat` file
already exists, the script `run` will not execute the correspond module.
- Some modules have a time stamp & progress indicator. That is, it will take
long time to finish.
- See [`run.m`](DESIGN.md#runm) for details.

Design
======

[`DESIGN.md`](DESIGN.md) describes the design of the modules and simulation. See
[`DESIGN.md`](DESIGN.md) for details.

Contact
=======

- Seonyeong Heo: [heosy@postech.ac.kr](mailto:heosy@postech.ac.kr)
- Seungbin Song: [sbsong@postech.ac.kr](mailto:sbsong@postech.ac.kr)
