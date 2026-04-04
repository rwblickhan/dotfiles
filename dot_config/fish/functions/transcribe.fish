function transcribe --description "Convert audio to WAV and transcribe with whisper-cpp"
    if test (count $argv) -eq 0
        echo "Usage: transcribe <input-file> [whisper-cli options...]"
        echo "Converts input to 16kHz mono WAV, then transcribes with whisper-cpp."
        echo "Output .txt is written to the current directory."
        return 1
    end

    set input $argv[1]
    set extra_args $argv[2..]

    if not test -f $input
        echo "Error: file not found: $input"
        return 1
    end

    set basename (path basename $input | sd '\.[^.]+$' '')
    set wav_tmp (mktemp /tmp/whisper-XXXXXX.wav)
    set output_base (pwd)/$basename

    echo "Converting $input -> $wav_tmp"
    ffmpeg -i $input -ar 16000 -ac 1 -c:a pcm_s16le $wav_tmp -y -loglevel error
    or begin
        rm -f $wav_tmp
        echo "Error: ffmpeg conversion failed"
        return 1
    end

    echo "Transcribing -> $output_base.txt"
    whisper-cli \
        -m ~/Developer/ggml-large-v3-turbo.bin \
        -f $wav_tmp \
        -of $output_base \
        --output-txt \
        $extra_args
    set result $status

    rm -f $wav_tmp

    if test $result -eq 0
        echo "Transcript saved to $output_base.txt"
    else
        echo "Error: whisper-cli failed"
        return $result
    end
end
