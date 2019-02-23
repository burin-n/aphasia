#!/bin/bash

. cmd.sh

stage=8
use_gpu=false
#target_test=test_disabilities
target_test=test_dhealthy
ndecode=1
data_dir=data
dir=exp/nnet2_online/nnet_ms_a
set -e
. cmd.sh
. ./path.sh
. ./utils/parse_options.sh

# assume use_gpu=true since it would be way too slow otherwise.

if ! cuda-compiled; then
  cat <<EOF && exit 1
This script is intended to be used with GPUs but you have not compiled Kaldi with CUDA
If you want to use GPUs (and have them), go to src/, and configure and make on a machine
where "nvcc" is installed.
EOF
fi

COUNTER=final
#while [  $COUNTER -le 32 ]; do

if [ $stage -le 7 ]; then
  steps/online/nnet2/prepare_online_decoding.sh --mfcc-config conf/mfcc_hires.conf --iter $COUNTER \
  ${data_dir}/lang exp/nnet2_online/extractor "$dir" ${dir}_online || exit 1;
fi

#echo "iter $COUNTER"
if [ $stage -le 8 ]; then
  # do the actual online decoding with iVectors, carrying info forward from
  # previous utterances of the same speaker.
  steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj $ndecode --iter $COUNTER \
	exp/tri3b/graph ${data_dir}/${target_test} ${dir}_online/decode_${target_test}_${COUNTER} || exit 1;
fi

if [ $stage -le 9 ]; then
 # this version of the decoding treats each utterance separately
 # without carrying forward speaker information.
 steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj $ndecode --iter $COUNTER \
   --per-utt true \
    exp/tri3b/graph ${data_dir}/${target_test} ${dir}_online/decode_${target_test}_utt_${COUNTER} || exit 1;
fi

if [ $stage -le 10 ]; then
  # this version of the decoding treats each utterance separately
  # without carrying forward speaker information, but looks to the end
  # of the utterance while computing the iVector.
  steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj $ndecode --iter $COUNTER \
	  --per-utt true --online false \
  exp/tri3b/graph ${data_dir}/${target_test} ${dir}_online/decode_${target_test}_utt_offline_${COUNTER} || exit 1;
fi

#  let COUNTER=COUNTER+1 
#done

exit 0;
