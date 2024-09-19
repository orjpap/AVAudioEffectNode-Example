//
//  SymClipNode.swift
//  AVAudioEffectNodeExample
//
//  Created by Orestis Papadopoulos on 19/9/24.
//

import AVFoundation

let symClipThreshold: Float = 1.0/3.0 // higher denominator > more clipping

let symClipNode = AVAudioEffectNode(renderBlock: { actionFlags, timestamp, frameCount, outputBusNumber, outputData, renderEvent, pullInputBlock -> AUAudioUnitStatus in

    // Pull the audio from the input
    let inputStatus = pullInputBlock?(actionFlags, timestamp, frameCount, 0, outputData)

    if inputStatus != noErr {
        return inputStatus ?? kAudioUnitErr_FailedInitialization
    }

    let ablPointer = UnsafeMutableAudioBufferListPointer(outputData)
    for buffer in ablPointer {
        let input = UnsafePointer<Float>(buffer.mData!.assumingMemoryBound(to: Float.self))
        let outputBuffer = UnsafeMutablePointer<Float>(buffer.mData!.assumingMemoryBound(to: Float.self))
        let processed = symClip(input: input, count: Int(frameCount))
        for i in 0..<Int(frameCount) {
            outputBuffer[i] = processed[i]
        }
    }

    return noErr
})

// "Overdrive" simlation with symmetrical clipping from DAFX (2011) translated to Swift
// Author: Dutilleux, Zölzer
// Symmetrical clipping clips both positive and negative amplitude peaks of a waveform evenly
func symClip(input: UnsafePointer<Float>, count: Int) -> [Float] {
    var output = [Float](repeating: 0.0, count: count)

    for i in 0..<count {
        let x = input[i]
        if abs(x) < symClipThreshold {
            output[i] = 2.0 * x
        } else if abs(x) >= symClipThreshold && abs(x) <= 2.0 * symClipThreshold {
            if x > 0 {
                output[i] = (3.0 - pow((2.0 - x * 3.0), 2.0)) / 3.0
            } else {
                output[i] = -(3.0 - pow((2.0 - abs(x) * 3.0), 2.0)) / 3.0
            }
        } else if abs(x) > 2.0 * symClipThreshold {
            if x > 0 {
                output[i] = 1.0
            } else {
                output[i] = -1.0
            }
        }
    }

    return output
}
