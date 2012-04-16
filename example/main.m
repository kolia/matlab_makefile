addpath(genpath('../code'))

close all ; clear all ;
% iterate_contexts({'plot_framelet_*'})
% iterate_contexts({'plot_filters_*' 'plot_center_*' 'plot_1D_*'}) ;

% iterate_contexts({'raw_data'}) ;

% iterate_contexts( 'prediction_*',{},@(contxt)contxt.ExperimentNum==2) ;
% iterate_contexts( 'plot_psth_prediction_*',{},@(contxt)contxt.ExperimentNum==2) ;

% iterate_contexts({'plot_center_*'}) ;

% close all ; clear all ;
% iterate_contexts({'infobound_*' 'repeats_*'},{},@(contxt)contxt.ExperimentNum==2) ;

close all ; clear all ;
iterate_contexts({'dkl_*'}) ;

% context = initialize_context() ;
% context.mode = 'GET' ;
% all_dkl = make_target(':all_dkl',context) ;

% context = initialize_context() ;
% make_target(':all_infos'    ,context) ;
% make_target(':plot_dkls_*'  ,context) ;
% make_target(':plot_firing_*',context) ;