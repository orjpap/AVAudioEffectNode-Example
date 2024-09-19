//
//  AVAudioEffectNode.swift
//  AVAudioEffectNodeExample
//
//  Created by Orestis Papadopoulos on 19/9/24.
//

import AVFoundation

extension AudioComponentDescription {
    static let AVAudioEffectNodeAU = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: fourCharCodeFrom("symc"), // "Symclip" in ASCII
        componentManufacturer: fourCharCodeFrom("orpa"), // "Opn" in ASCII (replace with your own identifier)
        componentFlags: 0,
        componentFlagsMask: 0
    )
}

func fourCharCodeFrom(_ string : String) -> FourCharCode {
    assert(string.count == 4, "String length must be 4")
    var result : FourCharCode = 0
    for char in string.utf16 {
        result = (result << 8) + FourCharCode(char)
    }
    return result
}

class AVAudioEffectNode: AVAudioUnitEffect {
    convenience init(renderBlock: @escaping AUInternalRenderBlock) {
        AUAudioUnit.registerSubclass(AVAudioEffectNodeAU.self,
                                     as: .AVAudioEffectNodeAU,
                                     name: "AVAudioEffectNode",
                                     version: 0)

        self.init(audioComponentDescription: .AVAudioEffectNodeAU)

        let audioEffectAudioUnit = self.auAudioUnit as! AVAudioEffectNodeAU
        audioEffectAudioUnit._internalRenderBlock = renderBlock
    }

    class AVAudioEffectNodeAU: AUAudioUnit {
        let inputBus: AUAudioUnitBus
        let outputBus: AUAudioUnitBus

        var _internalRenderBlock: AUInternalRenderBlock

        public override init(
            componentDescription: AudioComponentDescription,
            options: AudioComponentInstantiationOptions = []
        ) throws {
            let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

            inputBus = try AUAudioUnitBus(format: audioFormat)
            outputBus = try AUAudioUnitBus(format: audioFormat)

            _internalRenderBlock = { _, _, _, _, _, _, _ in
                return kAudioUnitErr_Uninitialized
            }

            try super.init(componentDescription: componentDescription, options: options)
        }

        public override var inputBusses: AUAudioUnitBusArray {
            return AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [inputBus])
        }


        public override var outputBusses: AUAudioUnitBusArray {
            return AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])
        }

        public override var internalRenderBlock: AUInternalRenderBlock {
            return _internalRenderBlock
        }
    }
}
