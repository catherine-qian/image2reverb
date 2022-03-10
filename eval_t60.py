import sys
import os
import numpy
import scipy.stats
import soundfile
import pyroomacoustics


def main():
    # input_dir = sys.argv[1]
    # output_dir = sys.argv[2]
    
    input_dir = sys.argv[1] if len(sys.argv)>1 else './datasets/image2reverb/test_B/'
    output_dir = sys.argv[2] if len(sys.argv)>2 else './image2reverb_Nonetest/small'

    files = []
    for d, a, f in os.walk(output_dir):
        file = [fn for fn in f if fn.endswith(".wav")]
        if len(file):
            files.append(os.path.join(d, file[0]))
    t60_err = []
    for f in files:
        print(f)
        f_input = os.path.join(input_dir, os.path.basename(f.replace(".wav", "_img.wav")))
        try:
            print(f, f_input)
            t60_d, a, b = compare_t60(f, f_input)
            print("%.2f%%: ================> %.2fs %.2fs" % (t60_d * 100, a, b))
            t60_err.append(t60_d)
        except Exception as error:
            print("Error.", error)
    numpy.save("t60", t60_err)
    print(scipy.stats.describe(t60_err))


def compare_t60(a, b):
    a, sr = soundfile.read(a) # sr=22050, sample rate
    b, sr2 = soundfile.read(b)


    t_a = pyroomacoustics.experimental.rt60.measure_rt60(a, sr)
    t_b = pyroomacoustics.experimental.rt60.measure_rt60(b, sr2, rt60_tgt=t_a)
    return ((t_b - t_a)/t_a), t_a, t_b


if __name__ == "__main__":
    main()