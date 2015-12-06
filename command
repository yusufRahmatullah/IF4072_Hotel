HParse grammar wdnet
HDMan -m -w wlist -n monophones1 -l dlog dict lexicon
# ubah dict, tambahin SENT-END dan SENT-START
HLEd -l '*' -d dict -i phones0.mlf mkphones0.led words.mlf

HCopy -T 1 -C mfccConfig -S mfccTargetList -F WAV
HCompV -C mfccConfig -f 0.01 -m -S mfccList -M model/hmm0 proto

HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm0/macros -H model/hmm0/hmmdefs -M model/hmm1 monophones0
HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm1/macros -H model/hmm1/hmmdefs -M model/hmm2 monophones0
HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm2/macros -H model/hmm2/hmmdefs -M model/hmm3 monophones0

# edit model/hmm3/hmmdefs, tambahin ~h "sp"
# copy model/hmm3/* ke model/hmm4/*
# add sil in monophones1
HHEd -H model/hmm4/macros -H model/hmm4/hmmdefs -M model/hmm5 sil.hed monophones1

HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm5/macros -H model/hmm5/hmmdefs -M model/hmm6 monophones1
HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm6/macros -H model/hmm6/hmmdefs -M model/hmm7 monophones1

HVite -C mfccConfig -l '*' -o SWT -b SENT-END -b SENT-START -a -H model/hmm7/macros -H model/hmm7/hmmdefs -i aligned.mlf -m -t 250.0 -y lab -I words.mlf -S mfccList dict monophones1
HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm7/macros -H model/hmm7/hmmdefs -M model/hmm8 monophones1
HERest -C mfccConfig -I phones0.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm8/macros -H model/hmm8/hmmdefs -M model/hmm9 monophones1

HLEd -n triphones1 -l '*' -i wintri.mlf mktri.led aligned.mlf
HHEd -H model/hmm9/macros -H model/hmm9/hmmdefs -M model/hmm10 mktri.hed monophones1

# kalau error, buka wintri.mlf isi yg kosong dari wintri_backup.mlf
HERest -C mfccConfig -I wintri.mlf -t 250.0 150.0 1000.0 -S mfccList -H model/hmm10/macros -H model/hmm10/hmmdefs -M model/hmm11 triphones1
HERest -C mfccConfig -I wintri.mlf -t 250.0 150.0 100.0 -s stats -S mfccList -H model/hmm11/macros -H model/hmm11/hmmdefs -M model/hmm12 triphones1

HDMan -b sp -n fulllist -g global-tri.ded -l flog lexicon-tri lexicon
HHEd -H model/hmm12/macros -H model/hmm12/hmmdefs -M model/hmm13 tree.hed triphones1 > log
# ubah tiedlist tambahin sil
# edit tambahin ~h "sil" model/hmm12/hmmdefs ke model/hmm13/hmmdefs
HERest -T 10 -C mfccConfig -I wintri.mlf -t 250.0 150.0 100.0 -s stats -S mfccList -H model/hmm13/macros -H model/hmm13/hmmdefs -M model/hmm14 tiedlist
HERest -T 10 -C mfccConfig -I wintri.mlf -t 250.0 150.0 100.0 -s stats -S mfccList -H model/hmm14/macros -H model/hmm14/hmmdefs -M model/hmm15 tiedlist

# testing
HVite -H model/hmm15/macros -H model/hmm15/hmmdefs -S testList -l '*' -i recout.mlf -w wdnet -p 0.0 -s 5.0 dict tiedlist
HResults -I testref.mlf tiedlist recout.mlf