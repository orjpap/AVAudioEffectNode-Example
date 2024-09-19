//
//  main.swift
//  AVAudioEffectNodeExample
//
//  Created by Orestis Papadopoulos on 19/9/24.
//

import AVFoundation

let engine = AVAudioEngine()

engine.attach(sineWaveNode)
engine.attach(symClipNode)

engine.connect(sineWaveNode, to: symClipNode, format: nil)
engine.connect(symClipNode, to: engine.mainMixerNode, format: nil)

engine.mainMixerNode.volume = 0.4

try! engine.start()
CFRunLoopRun()
engine.stop()
