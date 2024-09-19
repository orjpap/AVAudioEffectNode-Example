//
//  SinewaveOsc.swift
//  AVAudioEffectNodeExample
//
//  Created by Orestis Papadopoulos on 19/9/24.
//

import AVFoundation

// Create a sample rate and sine wave parameters
let sampleRate = 44100.0
let frequency = 440.0
let amplitude = 0.5
var phase = 0.0

// Define a source node to generate the sine wave
let sineWaveNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
    let deltaPhase = 2.0 * Double.pi * frequency / sampleRate

    // Loop through each frame and buffer
    for frame in 0..<Int(frameCount) {
        let sampleValue = sin(phase) * amplitude
        phase += deltaPhase
        if phase >= 2.0 * Double.pi {
            phase -= 2.0 * Double.pi
        }

        // Fill each channel with the sine wave sample
        for buffer in ablPointer {
            let bufferPointer = buffer.mData?.assumingMemoryBound(to: Float.self)
            bufferPointer?[frame] = Float(sampleValue)
        }
    }

    return noErr
}
