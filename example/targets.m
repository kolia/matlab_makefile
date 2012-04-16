BinSize = 40  ;  % Bin time length, in samples (1/10th ms).
COV_indices     = {[] 1 2 3 1:2 2:3 [1 3] 1:3} ;
powers = [10 ; 20 ; 30 ; 50 ; 80 ; 130 ; 210 ; 340 ; 550 ; 890] ; % spike history parameterization
N_isi = 1 ;
timestep  = 10 ;
timesteps = 35 ;

SAVE_HERE.ROOT_DIRECTORY = sprintf('%s/results',pwd) ;
SAVE_HERE.USING_FOLDERS  = { 'ExperimentNum' @(contxt)sprintf('Experiment_%d',contxt.ExperimentNum) ;
                             'CellNum'       @(contxt)sprintf('Cell_%d',contxt.CellNum  ) ;
                             'RunNum'        @(contxt)sprintf('Run_%d' ,contxt.RunNum   ) ;
                             'PastType'      @(contxt)sprintf('%s'     ,contxt.PastType ) } ;

t.UseRuns                           = { @load_result
                                            { @sprintf
                                                '%s/../DATA/Experiment_%d/UseRuns'
                                                pwd
                                                ':ExperimentNum'}           } ;

t.GoodCells                         = { @load_result
                                            { @sprintf
                                                '%s/../DATA/Experiment_%d/GoodCells'
                                                pwd
                                                ':ExperimentNum'}           } ;

t.CellNums                          = { @load_result
                                            { @sprintf
                                                '%s/../DATA/Experiment_%d/CellNums'
                                                pwd
                                                ':ExperimentNum'}           } ;

t.RecordStart                       = { @load_result
                                            { @sprintf
                                                '%s/../DATA/Experiment_%d/RecordStart'
                                                pwd
                                                ':ExperimentNum'}           } ;

t.StimulusSource                    = { @load_result
                                            { @sprintf
                                                '%s/../DATA/Experiment_%d/StimulusSource'
                                                pwd
                                                ':ExperimentNum'}           } ;

t.RecordsFolder                     = { @sprintf
                                            '%s/../DATA/Experiment_%d/records'
                                            pwd
                                            ':ExperimentNum'                } ;

t.framelet_moments.SAVE             = { @make_framelet_moments
                                            ':GoodCells'
                                            ':CellNum'
                                            ':StimulusSource'
                                            ':RecordsFolder'
                                             BinSize                        } ;

t.framelet_moments_reference.SAVE   = { @make_framelet_moments_reference
                                            ':GoodCells'
                                            ':StimulusSource'
                                            ':RecordsFolder'
                                             BinSize                        } ;

t.framelet_score.SAVE               = { @make_framelet_scores
                                            ':framelet_moments_reference'
                                            ':framelet_moments'
                                            ':UseRuns'                      } ;

t.framelet_data.SAVE                = { @make_framelet_data
                                            ':GoodCells'
                                            ':CellNum'
                                            ':RunNum'
                                            ':framelet_score'
                                            ':StimulusSource'
                                            ':RecordsFolder'
                                             BinSize                        } ;

% t.framelet_data.FIX                 = { @fix_framelet_data
%                                             '$FIX'
%                                             ':StimulusSource'
%                                             ':RecordsFolder'
%                                              BinSize
%                                             ':CellNum'
%                                             ':RunNum'                       } ;

t.train_data                        = { @make_data 'train' ':PastType' ':framelet_data' ':spike_hist'} ;
t.valid_data                        = { @make_data 'valid' ':PastType' ':framelet_data' ':spike_hist'} ;
t.test_data                         = { @make_data 'test'  ':PastType' ':framelet_data' ':spike_hist'} ;


t.raw_data.SAVE                     = { @make_raw_data
                                            ':GoodCells'
                                            ':CellNum'
                                            ':RunNum'
                                            ':StimulusSource'
                                            ':RecordsFolder'
                                            100
                                            300
                                            30
                                            89:138                          } ;

t.raw_data_train                    = { @make_data 'train' 'stim' ':raw_data' } ;
t.raw_data_test                     = { @make_data 'test'  'stim' ':raw_data' } ;

t.spike_hist.SAVE                   = { @make_spike_hist
                                            ':framelet_data'
                                            ':GoodCells'
                                            ':CellNums'
                                            ':RunNum'
                                            powers
                                            N_isi                           } ;

t.regularizer_penalty               = { @make_regularizer_penalty
                                            ':PastType'
                                            powers
                                            ':CellNums'
                                            N_isi
                                            timestep
                                            timesteps                       } ;

t.GLM.SAVE                          = { @make_GLM
                                            '$SELF'
                                            ':regularizer_penalty'
                                            ':train_data'
                                            ':valid_data'                   } ;

t.psth_spikes                       = { @make_psth_spikes
                                            ':GoodCells'
                                            ':CellNum'
                                            ':RunNum'
                                            ':RecordStart'
                                            'spikes'                        } ;

t.infobound_NN.SAVE                 = { @make_infobound_NN
                                            ':psth_spikes'                  } ;

t.repeats_firing_rate.SAVE          = { @make_repeats_firing_rate
                                            ':psth_spikes'                  } ;

t.model_STA.SAVE                    = { @make_model_STA
                                            ':train_data'                   } ;

% t.model_dSTA.SAVE                   = { @make_model_dSTA
%                                             ':train_data'
%                                             ':framelet_score'               } ;

t.model_COV.SAVE                    = { @make_model_COV_hint
                                            ':train_data'
                                            ':valid_data'
                                            ':model_*'                      } ;

t.model_rawSTA.SAVE                 = { @make_model_STA
                                            ':raw_data_train'               } ;

% t.model_NL_GAUSS.SAVE               = { @make_model_dkl_exp_polynomial
%                                             ':train_data'
%                                             { @make_model_dimensions
%                                                 ':model_COV_*'
%                                                 COV_indices         }
%                                             2                               } ;

t.model_NL_kde                      = { @make_model_NL_kde
                                            ':train_data'
                                            { @make_model_dimensions
                                                ':model_COV_*'
                                                COV_indices         }       } ;

t.model_1D_kde                      = { @make_model_NL_kde
                                            ':train_data'
                                            { @make_model_dimensions
                                                ':model_COV_*'
                                                num2cell(1:10)
                                                'no hint'           }       } ;

t.model_NL_factorized               = { @make_model_NL_factorized
                                            ':model_1D_*'                   } ;

t.dkl_1D_kde_STA.SAVE               = { @make_dkl_NN
                                            ':test_data'
                                            ':model_1D_kde_STA'             } ;

t.dkl_NL.SAVE                       = { @make_dkl_NN
                                            ':test_data'
                                            ':model_NL_*'                   } ;

t.dkl_direct.SAVE                   = { @make_dkl_NN
                                            ':test_data'
                                            { @make_model_dimensions
                                                ':model_COV_*'
                                                COV_indices         }       } ;

t.dkl_rawSTA.SAVE                   = { @make_dkl_NN
                                            ':raw_data_test'
                                            ':model_rawSTA'                 } ;

t.all_dkl.SAVE                      = { @iterate_contexts
                                            {'dkl_NL_*' 'dkl_direct_*'}     } ;

t.all_infos.SAVE                    = { @iterate_contexts
                                            {'infobound_*' 'repeats_*'}
                                            { @make_these 'R' ':all_dkl'}
                                            @(contxt)contxt.ExperimentNum==2} ;

t.center_timecourse                 = { @make_center_timecourse
                                            ':model_STA'
                                            ':framelet_score'               } ;

t.all_center_timecourse.SAVE        = { @iterate_contexts
                                            'center_timecourse'
                                            {}
                                            @(contxt,ExpNum)contxt.ExperimentNum==ExpNum
                                            ':ExperimentNum'                } ;

t.cell_types_by_hand                = { @cell_types_by_hand
                                            ':ExperimentNum'                } ;

t.plot_center_timecourses.SAVE      = { @make_plot_center_timecourses
                                            '$SELF'
                                            ':all_center_timecourse'
                                            ':cell_types_by_hand'
                                            ':ExperimentNum'                } ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% REPEATS PREDICITONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t.all_framelet_score.SAVE           = { @iterate_contexts
                                            'framelet_score'
                                            {}
                                            @(contxt)contxt.ExperimentNum==2} ;

t.framelet_repeat_range_200000_1_30000 = [200000 1 30000] ;
t.framelet_repeat_range_260000_1_30000 = [260000 1 30000] ;
t.framelet_repeat_range_160000_1_30000 = [160000 1 30000] ;
t.framelet_repeat_range_100000_1_30000 = [100000 1 30000] ;
t.framelet_repeat_range_40000_1_30000 = [40000 1 30000] ;

t.framelet_repeat_range_230000_1_30000 = [230000 1 30000] ;
t.framelet_repeat_range_130000_1_30000 = [130000 1 30000] ;
t.framelet_repeat_range_70000_1_30000 = [70000 1 30000] ;
t.framelet_repeat_range_10000_1_30000 = [10000 1 30000] ;

t.framelet_repeat_datastore.SAVE    = { @make_framelet_repeat_datastore
                                            ':all_framelet_score'
                                            ':StimulusSource'
                                            '../DATA/records'
                                            ':framelet_repeat_range_*'
                                             BinSize                        } ;

t.framelet_repeat_data              = { @make_framelet_repeat_data 
                                            ':framelet_repeat_datastore_*'
                                            ':framelet_score'               } ;

t.prediction__kde_STA.SAVE          = { @make_model_prediction
                                            ':model_NL_kde_STA'
                                            ':dkl_kde_STA'
                                            ':framelet_repeat_data_*'
                                            ':repeats_firing_rate'          } ;

t.plot_psth_prediction.SAVE         = { @make_plot_psth_prediction
                                            '$SELF'
                                            ':prediction_*'
                                            ':psth_spikes'
                                            ':CellNum'
                                            10                              } ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


t.plot_framelet_scores.SAVE         = { @make_plot_framelet_scores
                                            '$SELF'
                                            ':framelet_score'               } ;

% t.plot_filters.SAVE                 = { @make_plot_filters 
%                                             '$SELF'
%                                             ':framelet_score'
%                                             ':model_COV_*'
%                                             @title_gen_plot_filters         
%                                             ':CellNum'                      } ;

t.plot_filters_ratios.SAVE          = { @make_plot_filters_ratios
                                            '$SELF'
                                            ':model_1D_kde_*'                  
                                            ':framelet_score'
                                            ':test_data'
                                            ':dkl_1D_kde_STA'
                                            ':PastType'
                                            powers                          } ;


% t.plot_1D_ratios_STA.SAVE           = { @make_plot_1D_ratios
%                                             '$SELF'
%                                             ':test_data'
%                                             ':model_1D_kde_STA'
%                                             ':dkl_1D_kde_STA'               } ;

t.plot_firing_rate_infobound.SAVE   = { @make_plot_scatter
                                            '$SELF'
                                            ':all_infos'
                                            'scatter'
                                            @(x)x.repeats_firing_rate
                                            @(x)x.infobound_NN
                                            {'Firing rate vs. info bound'               @(s)title(s)}
                                            {'firing rate'                              @(s)xlabel(s,'FontSize',32)}
                                            {'info bound    (bits)'                     @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
t.plot_firing_rate_COVmax_kde.SAVE  = { @make_plot_scatter
                                            '$SELF'
                                            ':all_infos'
                                            'scatter'
                                            @(x)x.repeats_firing_rate
                                            @(x)get_max(x.dkl_NL_kde_STA.dkl,1:8)
                                            {'Firing rate vs. COV'                      @(s)title(s)}
                                            {'firing rate'                              @(s)xlabel(s,'FontSize',32)}
                                            {'Info of COV KDE model  (bits)'            @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
% t.plot_dkls_STA_COVmax_GAUSS.SAVE   = { @make_plot_scatter
%                                             '$SELF'
%                                             ':all_dkl'
%                                             'comparison'
%                                             @(x)x.dkl_direct_STA.dkl{1}
%                                             @(x)get_max(x.dkl_NL_GAUSS_STA.dkl,1:8)
%                                             {'Information captured: STA vs. COV'        @(s)title(s)}
%                                             {'STA'                                      @(s)xlabel(s,'FontSize',32)}
%                                             {'gaussian ratio'                           @(s)ylabel(s,'FontSize',32)}
%                                                                             } ;

t.plot_dkls_hist_STA.SAVE           = { @make_plot_hist
                                            '$SELF'
                                            ':all_infos'
                                            @(x)100*x.dkl_direct_STA.dkl{1}./x.infobound_NN
                                            {'Information captured by STA'              @(s)title( s,'FontSize',32)}
                                            {'% of information bound'                   @(s)xlabel(s,'FontSize',32)}
                                            {'number of cell runs'                      @(s)ylabel(s,'FontSize',32)}
                                            {[0 100] @(x)xlim(x)}
                                                                            } ;

t.plot_dkls_hist_COV.SAVE           = { @make_plot_hist
                                            '$SELF'
                                            ':all_infos'
                                            @(x)100*get_max(x.dkl_NL_kde_STA.dkl,1:8)./x.infobound_NN
                                            {'Information captured by COV'              @(s)title( s,'FontSize',32)}
                                            {'% of information bound'                   @(s)xlabel(s,'FontSize',32)}
                                            {'number of cell runs'                      @(s)ylabel(s,'FontSize',32)}
                                            {[0 100] @(x)xlim(x)}
                                                                            } ;
t.plot_dkls_STA_COVmax_kde.SAVE     = { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)x.dkl_direct_STA.dkl{1}
                                            @(x)get_max(x.dkl_NL_kde_STA.dkl,1:8)
                                            {'Information captured:    STA vs. COV'     @(s)title( s,'FontSize',32)}
                                            {'Info of STA   (bits/spike)'               @(s)xlabel(s,'FontSize',28)}
                                            {'Info of COV KDE model  (bits/spike)'      @(s)ylabel(s,'FontSize',28)}
                                                                            } ;
%                                             {[0 3.2]   @(x)xlim(x)}
%                                             {[0 3.5]   @(x)ylim(x)}

t.plot_dkls_STA_COVmax4_fact.SAVE   = { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)x.dkl_direct_STA.dkl{1}
                                            @(x)get_max(x.dkl_NL_factorized_kde_STA.dkl,1:8)
                                            {'Information captured:    STA vs. COV'     @(s)title( s,'FontSize',32)}
                                            {'Info of STA   (bits/spike)'               @(s)xlabel(s,'FontSize',28)}
                                            {'Info of factorized model  (bits/spike)'   @(s)ylabel(s,'FontSize',28)}
                                                                            } ;
%                                             {[0 3.2]   @(x)xlim(x)}
%                                             {[0 3.5]   @(x)ylim(x)}

t.plot_dkls_max4_kde_fact.SAVE      = { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)get_max(x.dkl_NL_kde_STA.dkl,1:8)
                                            @(x)get_max(x.dkl_NL_factorized_kde_STA.dkl,1:8)
                                            {'Information captured by up to 4 filters'  @(s)title(s)}
                                            {'Info of COV KDE model  (bits)'            @(s)xlabel(s,'FontSize',32)}
                                            {'Info of factorized model   (bits)'        @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
t.plot_dkls_max4_kde_direct.SAVE    = { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)get_max(x.dkl_NL_kde_STA.dkl,1:8)
                                            @(x)get_max(x.dkl_direct_STA.dkl,1:8)
                                            {'Information captured by up to 4 filters'  @(s)title(s)}
                                            {'Info of COV KDE model  (bits/spike)'      @(s)xlabel(s,'FontSize',32)}
                                            {'Info of linear filters  (bits/spike)'     @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
% t.plot_dkls_max4_GAUSS_fact.SAVE    = { @make_plot_scatter
%                                             '$SELF'
%                                             ':all_dkl'
%                                             'comparison'
%                                             @(x)get_max(x.dkl_NL_GAUSS_STA.dkl,1:8)
%                                             @(x)get_max(x.dkl_NL_factorized_kde_STA.dkl,1:8)
%                                             {'Information captured by up to 4 filters'  @(s)title(s)}
%                                             {'gaussian ratio'                           @(s)xlabel(s,'FontSize',32)}
%                                             {'factorized kernel smoothed'               @(s)ylabel(s,'FontSize',32)}
%                                                                             } ;
% t.plot_dkls_max4_GAUSS_kde.SAVE     = { @make_plot_scatter
%                                             '$SELF'
%                                             ':all_dkl'
%                                             'comparison'
%                                             @(x)get_max(x.dkl_NL_GAUSS_STA.dkl,1:8)
%                                             @(x)get_max(x.dkl_NL_kde_STA.dkl,1:8)
%                                             {'Information captured by up to 4 filters'  @(s)title(s)}
%                                             {'gaussian ratio'                           @(s)xlabel(s,'FontSize',32)}
%                                             {'kernel smoothed'                          @(s)ylabel(s,'FontSize',32)}
%                                                                             } ;
for i=1:8
% t.(sprintf('plot_dkls_GAUSS_kde_%d',i)).SAVE = ...
%                                       { @make_plot_scatter
%                                             '$SELF'
%                                             ':all_dkl'
%                                             'comparison'
%                                             @(x)x.dkl_NL_GAUSS_STA.dkl{i}
%                                             @(x)x.dkl_NL_kde_STA.dkl{i}
%                                             {sprintf('Info of filters #%d (bits)',i)    @(s)title(s)}
%                                             {'gaussian ratio'                           @(s)xlabel(s,'FontSize',32)}
%                                             {'kernel smoothed'                          @(s)ylabel(s,'FontSize',32)}
%                                                                             } ;
% t.(sprintf('plot_dkls_GAUSS_fact_%d',i)).SAVE = ...
%                                       { @make_plot_scatter
%                                             '$SELF'
%                                             ':all_dkl'
%                                             'comparison'
%                                             @(x)x.dkl_NL_GAUSS_STA.dkl{i}
%                                             @(x)x.dkl_NL_factorized_kde_STA.dkl{i}
%                                             {sprintf('Info of filters #%d (bits)',i)    @(s)title(s)}
%                                             {'gaussian ratio'                           @(s)xlabel(s,'FontSize',32)}
%                                             {'factorized kernel smoothed'               @(s)ylabel(s,'FontSize',32)}
%                                                                             } ;
t.(sprintf('plot_dkls_kde_fact_%d',i)).SAVE = ...
                                      { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)x.dkl_NL_kde_STA.dkl{i}
                                            @(x)x.dkl_NL_factorized_kde_STA.dkl{i}
                                            {sprintf('Info of filters #%d (bits)',i)    @(s)title(s)}
                                            {'Info of COV KDE model  (bits)'            @(s)xlabel(s,'FontSize',32)}
                                            {'Info of factorized model  (bits)'         @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
t.(sprintf('plot_dkls_kde_direct_%d',i)).SAVE = ...
                                      { @make_plot_scatter
                                            '$SELF'
                                            ':all_dkl'
                                            'comparison'
                                            @(x)x.dkl_NL_kde_STA.dkl{i}
                                            @(x)x.dkl_direct_STA.dkl{i}
                                            {sprintf('Info of filters #%d (bits)',i)    @(s)title(s)}
                                            {'Info of COV KDE model  (bits)'            @(s)xlabel(s,'FontSize',32)}
                                            {'Info of linear filters  (bits)'           @(s)ylabel(s,'FontSize',32)}
                                                                            } ;
end