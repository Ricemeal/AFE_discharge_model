# AFE_discharge_model
Do the simulation of dicharge for AFE. Before that, please prepare your dadasets for nonlinear AFE.
keyword: discharge, nonlinear, antiferroelectric
## Demo File Description
3 files are main parts in this project, eg. __Forc.m__, __forc2hys.m__, __discharge_sim.m__.
Please follow the instruction in these ".m" files.
| File     | Description                                                                |
| -------- | -------------------------------------------------------------------------- |
| Forc.m   | Neural network for simulation of \rou in Preisach model                    |
| forc2hys.m | apply the neural netwrok and reversal parts to calculate hysteresis loops. |
| discharge_sim.m | apply the verified model to discharge simulation. |
| Preisach2PE.m | self-defined function, which is invoked in "discharge_sim.m" to calculate the P-E relation of Preisach part. |
| find_nearest.m | self-defined function. |
| ./matlab_data/P_rev.mat | integrated results of reversiable part of P_rev for antiferroelectric type B|
| ./matlab_data/E_rev.mat | E_rev for P_rev|
| ./matlab_data/Ex_Ey_rou.mat | Preisach datasets of antiferroelectric type B|
| ./matlab_data/neural_net_of_Preisach.mat | the neural network simulation of \rou|
| ./matlab_data/dQ.mat | intermediate saved data during calcution in forc2hys.m. Save time for repeating calculation|
