#!/bin/bash

. cmd.sh
. ./path.sh

stage=11
ndecode=1
dir=nbest
#lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_atypical_utt_offline_final
#lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_dhealthy_utt_offline_final
lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_dhealthy_final
#lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_disabilities_utt_offline_final
#lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_disabilities_final
#lattice_dir=exp/nnet2_online/nnet_ms_a_online/decode_test_disabilities_utt_offline_final



nbest=30

mkdir nbest

if [ $stage -le 11 ]; then
    for i in $(seq 1 $ndecode); do
        echo "gunzip -c $lattice_dir/lat.$i.gz|"
        lattice-to-nbest --n=$nbest ark:"gunzip -c $lattice_dir/lat.$i.gz|" ark:$dir/nbest.$i.lats
        lattice-copy ark:$dir/nbest.$i.lats ark,t:- | utils/int2sym.pl -f 3 data/lang_test/words.txt > $dir/nbest-sym-$i.txt
        lattice-copy ark:$dir/nbest.$i.lats ark,t:- > $dir/nbest-$i.txt
    done
fi


cat $dir/nbest-1.txt > $dir/nbest.txt
for i in $(seq 2 $ndecode); do
    cat $dir/nbest-$i.txt >> $dir/nbest.txt
done

cat $dir/nbest-sym-1.txt > $dir/nbest-sym.txt
for i in $(seq 2 $ndecode); do
    cat $dir/nbest-sym-$i.txt >> $dir/nbest-sym.txt
done

#cat $dir/nbest.txt | get_nbest.py > nbest.txt 
cat $dir/nbest-sym.txt | get_nbest.py > nbest.txt 
echo "saved to nbest.txt"
